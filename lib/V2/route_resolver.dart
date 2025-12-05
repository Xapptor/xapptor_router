import 'package:flutter/foundation.dart';
import 'package:xapptor_router/V2/app_screen_v2.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';
import 'package:xapptor_router/V2/route_resolution.dart';

/// Callback type for route resolution errors.
///
/// [route_name] is the route that failed to resolve.
/// [error] contains details about why resolution failed.
typedef OnRouteNotFound = void Function(String route_name, String error);

/// Callback type for successful route resolution.
///
/// [resolution] contains the resolved route information.
typedef OnRouteResolved = void Function(RouteResolutionV2 resolution);

/// Central route resolution engine for xapptor_router V2.
///
/// Provides a single source of truth for resolving route names to screens,
/// handling both static and dynamic routes uniformly.
///
/// ## Basic Usage
///
/// ```dart
/// final resolution = RouteResolverV2.resolve("event/abc123");
///
/// if (resolution.is_valid) {
///   print("Navigating to: ${resolution.full_path}");
///   print("Event ID: ${resolution.param('id')}");
/// } else {
///   print("Route not found");
/// }
/// ```
///
/// ## Resolution Strategy
///
/// 1. **Exact Match**: First tries to find a screen with an exact name match
/// 2. **Base Route Match**: If not found, removes the last path segment and
///    tries to match the base route (e.g., "event" for "event/abc123")
/// 3. **Dynamic Clone**: If base route matches, clones the screen with the
///    full path and registers it
///
/// ## Route Guards (Future)
///
/// The architecture supports adding route guards for authentication,
/// permissions, etc. See [canResolve] for basic validation.
///
/// ## Memory Management
///
/// Dynamic screens are automatically registered. Use [cleanup_dynamic_screens]
/// to remove unused dynamic screens and prevent memory leaks.
class RouteResolverV2 {
  // Private constructor prevents instantiation
  RouteResolverV2._();

  /// Global callback for route resolution errors.
  ///
  /// Set this to handle all route-not-found errors globally:
  ///
  /// ```dart
  /// RouteResolverV2.on_route_not_found = (route, error) {
  ///   analytics.logEvent('route_not_found', {'route': route});
  ///   showSnackBar('Page not found: $route');
  /// };
  /// ```
  static OnRouteNotFound? on_route_not_found;

  /// Global callback for successful route resolution.
  ///
  /// Useful for analytics or logging:
  ///
  /// ```dart
  /// RouteResolverV2.on_route_resolved = (resolution) {
  ///   analytics.logScreenView(resolution.full_path);
  /// };
  /// ```
  static OnRouteResolved? on_route_resolved;

  /// Resolves a route name to a [RouteResolutionV2].
  ///
  /// Supports both static routes ("home", "login") and dynamic routes
  /// ("event/abc123", "resumes/user_id").
  ///
  /// ## Parameters
  ///
  /// - [route_name]: The route to resolve (with or without leading slash)
  /// - [on_not_found]: Optional callback for this specific resolution failure
  /// - [on_resolved]: Optional callback for this specific resolution success
  ///
  /// ## Returns
  ///
  /// A [RouteResolutionV2] with [is_valid] indicating success or failure.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Simple resolution
  /// final resolution = RouteResolverV2.resolve("event/abc123");
  ///
  /// // With error handling
  /// final resolution = RouteResolverV2.resolve(
  ///   "event/abc123",
  ///   on_not_found: (route, error) => print("Error: $error"),
  ///   on_resolved: (res) => print("Success: ${res.full_path}"),
  /// );
  /// ```
  static RouteResolutionV2 resolve(
    String route_name, {
    OnRouteNotFound? on_not_found,
    OnRouteResolved? on_resolved,
  }) {
    final normalized = _normalize(route_name);

    if (normalized.isEmpty) {
      final resolution = RouteResolutionV2.notFound(route_name);
      _handle_not_found(route_name, "Empty route name", on_not_found);
      return resolution;
    }

    // Try exact match first, then base route match
    final resolution =
        _try_exact_match(normalized) ?? _try_base_route_match(normalized) ?? RouteResolutionV2.notFound(route_name);

    if (resolution.is_valid) {
      _handle_resolved(resolution, on_resolved);
    } else {
      _handle_not_found(route_name, "No matching route found", on_not_found);
    }

    return resolution;
  }

  /// Normalizes a route name by removing leading slash.
  static String _normalize(String route) {
    return route.startsWith('/') ? route.substring(1) : route;
  }

  /// Attempts to find an exact match in the screen registry.
  static RouteResolutionV2? _try_exact_match(String normalized) {
    final index = app_screens_v2.indexWhere((s) => s.name == normalized);

    if (index == -1) return null;

    return RouteResolutionV2(
      screen: app_screens_v2[index],
      index: index,
      was_dynamically_created: false,
      base_route: normalized,
      params: const {},
      full_path: normalized,
      is_valid: true,
    );
  }

  /// Attempts to match by removing the last path segment.
  static RouteResolutionV2? _try_base_route_match(String normalized) {
    final uri = Uri.parse(normalized);

    if (uri.pathSegments.length <= 1) return null;

    // Get base route (first segment)
    final base_route = uri.pathSegments.first;
    final base_screen = search_screen_v2(base_route);

    if (base_screen.name.isEmpty) {
      // Try with more segments (e.g., "home/courses" as base)
      return _try_multi_segment_base_match(uri, normalized);
    }

    // Clone and register
    final cloned = _create_dynamic_screen(base_screen, normalized);

    return RouteResolutionV2(
      screen: cloned,
      index: app_screens_v2.indexWhere((s) => s.name == normalized),
      was_dynamically_created: true,
      base_route: base_route,
      params: _extract_params(uri, 1),
      full_path: normalized,
      is_valid: true,
    );
  }

  /// Tries matching with multiple base segments (e.g., "home/courses/123").
  static RouteResolutionV2? _try_multi_segment_base_match(Uri uri, String normalized) {
    // Try progressively longer base routes
    for (int i = uri.pathSegments.length - 1; i > 0; i--) {
      final base_segments = uri.pathSegments.sublist(0, i);
      final base_route = base_segments.join('/');
      final base_screen = search_screen_v2(base_route);

      if (base_screen.name.isNotEmpty) {
        final cloned = _create_dynamic_screen(base_screen, normalized);

        return RouteResolutionV2(
          screen: cloned,
          index: app_screens_v2.indexWhere((s) => s.name == normalized),
          was_dynamically_created: true,
          base_route: base_route,
          params: _extract_params(uri, i),
          full_path: normalized,
          is_valid: true,
        );
      }
    }

    return null;
  }

  /// Creates a dynamic screen clone and registers it.
  static AppScreenV2 _create_dynamic_screen(AppScreenV2 base, String new_name) {
    final cloned = base.clone_with_path(new_name);
    add_new_app_screen_v2(cloned);
    return cloned;
  }

  /// Extracts parameters from path segments after the base route.
  ///
  /// [base_segment_count] indicates how many segments are part of the base route.
  static Map<String, String> _extract_params(Uri uri, int base_segment_count) {
    final params = <String, String>{};
    final param_segments = uri.pathSegments.sublist(base_segment_count);

    if (param_segments.isEmpty) return params;

    // Single param gets 'id', multiple get indexed names
    if (param_segments.length == 1) {
      params['id'] = param_segments.first;
    } else {
      for (int i = 0; i < param_segments.length; i++) {
        params['param_$i'] = param_segments[i];
      }
    }

    return params;
  }

  /// Handles route-not-found by calling callbacks.
  static void _handle_not_found(
    String route_name,
    String error,
    OnRouteNotFound? local_callback,
  ) {
    // Call local callback first
    local_callback?.call(route_name, error);

    // Then global callback
    on_route_not_found?.call(route_name, error);

    // Debug logging
    if (kDebugMode) {
      debugPrint('[RouteResolverV2] Route not found: "$route_name" - $error');
    }
  }

  /// Handles successful resolution by calling callbacks.
  static void _handle_resolved(
    RouteResolutionV2 resolution,
    OnRouteResolved? local_callback,
  ) {
    // Call local callback first
    local_callback?.call(resolution);

    // Then global callback
    on_route_resolved?.call(resolution);

    // Debug logging
    if (kDebugMode) {
      debugPrint('[RouteResolverV2] Resolved: ${resolution.full_path}'
          '${resolution.was_dynamically_created ? " (dynamic)" : ""}');
    }
  }

  /// Checks if a route would resolve successfully without actually resolving it.
  ///
  /// Useful for route guards, navigation validation, or conditional UI.
  ///
  /// ```dart
  /// if (RouteResolverV2.can_resolve("admin/dashboard")) {
  ///   showAdminButton();
  /// }
  /// ```
  static bool can_resolve(String route_name) {
    final normalized = _normalize(route_name);

    // Check exact match
    if (app_screens_v2.any((s) => s.name == normalized)) {
      return true;
    }

    // Check base route
    final uri = Uri.parse(normalized);
    if (uri.pathSegments.isEmpty) {
      return false;
    }

    // Try single segment base
    final base_route = uri.pathSegments.first;
    if (search_screen_v2(base_route).name.isNotEmpty) {
      return true;
    }

    // Try multi-segment base routes
    for (int i = uri.pathSegments.length - 1; i > 0; i--) {
      final base_segments = uri.pathSegments.sublist(0, i);
      final base = base_segments.join('/');
      if (search_screen_v2(base).name.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  /// Cleans up dynamically created screens that are no longer needed.
  ///
  /// Call this periodically or when navigating away from dynamic routes
  /// to prevent memory leaks from accumulated dynamic screens.
  ///
  /// ## Parameters
  ///
  /// - [except_route]: Optional route to keep (usually the current route)
  ///
  /// ## Example
  ///
  /// ```dart
  /// // In your navigation handler
  /// RouteResolverV2.cleanup_dynamic_screens(except_route: current_route);
  /// ```
  static void cleanup_dynamic_screens({String? except_route}) {
    app_screens_v2.removeWhere((screen) {
      // Don't remove the excepted route
      if (except_route != null && screen.name == except_route) {
        return false;
      }

      // Check if this is a dynamic screen (has more than one path segment)
      final uri = Uri.parse(screen.name);
      if (uri.pathSegments.length <= 1) {
        return false; // Base route, don't remove
      }

      // Check if base route exists (if so, this is a dynamic clone)
      final base_route = uri.pathSegments.first;
      return app_screens_v2.any((s) => s.name == base_route && s.name != screen.name);
    });

    if (kDebugMode) {
      debugPrint('[RouteResolverV2] Cleanup complete. '
          'Remaining screens: ${app_screens_v2.length}');
    }
  }

  /// Gets statistics about the current route registry.
  ///
  /// Useful for debugging and monitoring.
  ///
  /// ```dart
  /// final stats = RouteResolverV2.get_stats();
  /// print("Total screens: ${stats['total']}");
  /// print("Dynamic screens: ${stats['dynamic']}");
  /// ```
  static Map<String, int> get_stats() {
    int dynamic_count = 0;
    int static_count = 0;

    for (final screen in app_screens_v2) {
      final uri = Uri.parse(screen.name);
      if (uri.pathSegments.length > 1) {
        // Check if base exists
        final base = uri.pathSegments.first;
        if (app_screens_v2.any((s) => s.name == base && s.name != screen.name)) {
          dynamic_count++;
        } else {
          static_count++;
        }
      } else {
        static_count++;
      }
    }

    return {
      'total': app_screens_v2.length,
      'static': static_count,
      'dynamic': dynamic_count,
    };
  }
}
