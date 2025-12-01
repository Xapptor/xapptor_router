import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:xapptor_router/swipe_gesture_detector/enable_swipe_gesture_detector_listener.dart';
import 'package:xapptor_router/V2/app_screen_v2.dart';
import 'package:xapptor_router/V2/initial_values_routing_v2.dart';
import 'package:xapptor_router/V2/route_resolution.dart';
import 'package:xapptor_router/V2/route_resolver.dart';
import 'package:xapptor_router/V2/save_user_session_v2.dart';

/// Global list of registered app screens.
///
/// Screens are added via [add_new_app_screen_v2] and accessed during
/// route resolution and navigation.
///
/// ## Note
///
/// This is intentionally a global mutable list for performance and
/// simplicity. For dependency injection, wrap access in a service class.
List<AppScreenV2> app_screens_v2 = [];

/// Registers a new app screen.
///
/// The screen is added to [app_screens_v2]. If a screen with the same
/// name already exists, the duplicate is removed (keeping the newer one).
///
/// ## Example
///
/// ```dart
/// add_new_app_screen_v2(
///   AppScreenV2(
///     name: "home",
///     child: HomeScreen(),
///   ),
/// );
/// ```
///
/// ## Dynamic Routes
///
/// For routes that support dynamic segments, register only the base route:
///
/// ```dart
/// add_new_app_screen_v2(
///   AppScreenV2(
///     name: "event",  // NOT "event/:id"
///     child: EventView(),
///   ),
/// );
/// ```
///
/// The router will automatically create dynamic clones when navigating
/// to "event/abc123".
Future<void> add_new_app_screen_v2(AppScreenV2 new_screen) async {
  app_screens_v2.add(new_screen);

  // Remove duplicates (keep the newer one)
  List<AppScreenV2> screens = app_screens_v2
      .where((app_screen) => app_screen.name == new_screen.name)
      .toList();

  if (screens.length > 1) {
    int duplicate_screen_index =
        app_screens_v2.indexWhere((app_screen) => app_screen.name == new_screen.name);
    app_screens_v2.removeAt(duplicate_screen_index);
  }

  // Small delay to ensure screen is registered before navigation
  await Future.delayed(const Duration(milliseconds: 50));
}

/// Removes a screen by name.
///
/// Use this to unregister screens that are no longer needed.
///
/// ```dart
/// remove_screen_v2("old_feature");
/// ```
void remove_screen_v2(String app_screen_name) {
  app_screens_v2.removeWhere((app_screen) => app_screen.name == app_screen_name);
}

/// Opens a screen by name, supporting both static and dynamic routes.
///
/// This is the primary navigation function for xapptor_router V2.
/// It uses [RouteResolverV2] to resolve routes uniformly.
///
/// ## Static Routes
///
/// ```dart
/// open_screen_v2("home");      // Opens the home screen
/// open_screen_v2("login");     // Opens the login screen
/// open_screen_v2("settings");  // Opens the settings screen
/// ```
///
/// ## Dynamic Routes
///
/// ```dart
/// open_screen_v2("event/abc123");       // Opens event with ID "abc123"
/// open_screen_v2("resumes/user_id_en"); // Opens resume with dynamic ID
/// open_screen_v2("home/courses/123");   // Opens course details
/// ```
///
/// ## Accessing Route Parameters
///
/// After navigation, access parameters in your screen:
///
/// ```dart
/// // Method 1: Get last segment (simple)
/// final event_id = get_last_path_segment_v2();
///
/// // Method 2: Get full resolution (advanced)
/// final resolution = get_current_route_resolution_v2();
/// final event_id = resolution?.param('id');
/// ```
///
/// ## Error Handling
///
/// ```dart
/// final resolution = open_screen_v2(
///   "unknown/route",
///   on_not_found: (route, error) {
///     showSnackBar("Page not found: $route");
///   },
///   fallback_route: "home",  // Navigate here if not found
/// );
///
/// if (!resolution.is_valid) {
///   // Handle error
/// }
/// ```
///
/// ## Parameters
///
/// - [screen_name]: The route to navigate to
/// - [on_not_found]: Optional callback for route resolution failure
/// - [on_resolved]: Optional callback for successful resolution
/// - [fallback_route]: Optional route to navigate to if resolution fails
///
/// ## Returns
///
/// A [RouteResolutionV2] containing route information and parameters.
RouteResolutionV2 open_screen_v2(
  String screen_name, {
  OnRouteNotFound? on_not_found,
  OnRouteResolved? on_resolved,
  String? fallback_route,
}) {
  enable_swipe_gesture_detector_listener();

  // Use RouteResolver for unified resolution
  final resolution = RouteResolverV2.resolve(
    screen_name,
    on_not_found: on_not_found,
    on_resolved: on_resolved,
  );

  if (!resolution.is_valid) {
    // Try fallback route if provided
    if (fallback_route != null) {
      if (kDebugMode) {
        debugPrint('[open_screen_v2] Route not found: "$screen_name", '
            'falling back to "$fallback_route"');
      }
      return open_screen_v2(fallback_route);
    }

    // Route not found and no fallback
    if (kDebugMode) {
      debugPrint('[open_screen_v2] Route not found: "$screen_name"');
    }
    return resolution;
  }

  // Save session with the full path
  save_user_session_v2(resolution.full_path);

  // Navigate to the resolved screen
  handle_app_screen_opening_v2(resolution.index);

  return resolution;
}

/// Searches for a screen by exact name match.
///
/// Returns an empty [AppScreenV2] if not found.
///
/// ## Note
///
/// For route resolution with dynamic route support, use
/// [RouteResolverV2.resolve] instead.
///
/// ```dart
/// final screen = search_screen_v2("home");
/// if (screen.name.isNotEmpty) {
///   // Found
/// }
/// ```
AppScreenV2 search_screen_v2(String screen_name) {
  return app_screens_v2.singleWhere(
    (current_app_screen) => current_app_screen.name == screen_name,
    orElse: () => AppScreenV2.empty(),
  );
}

// ============================================================================
// Convenience Functions
// ============================================================================

/// Opens the login screen.
///
/// Equivalent to `open_screen_v2("login")`.
RouteResolutionV2 open_login_v2() => open_screen_v2("login");

/// Opens the registration screen.
///
/// Equivalent to `open_screen_v2("register")`.
RouteResolutionV2 open_register_v2() => open_screen_v2("register");

/// Opens the password restoration screen.
///
/// Equivalent to `open_screen_v2("restore_password")`.
RouteResolutionV2 open_restore_password_v2() => open_screen_v2("restore_password");
