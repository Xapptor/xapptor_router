import 'package:xapptor_router/V2/app_screen_v2.dart';

/// Represents the result of resolving a route.
///
/// Contains all information needed to navigate to a screen,
/// including whether a dynamic screen was created and extracted parameters.
///
/// ## Usage
///
/// ```dart
/// final resolution = RouteResolverV2.resolve("event/abc123");
///
/// if (resolution.is_valid) {
///   print("Base route: ${resolution.base_route}");     // "event"
///   print("Event ID: ${resolution.param('id')}");      // "abc123"
///   print("Full path: ${resolution.full_path}");       // "event/abc123"
///   print("Dynamic: ${resolution.was_dynamically_created}"); // true
/// }
/// ```
///
/// ## Parameter Access
///
/// For single-segment dynamic routes like "event/abc123":
/// - `resolution.param('id')` returns "abc123"
/// - `resolution.last_segment` returns "abc123"
///
/// For multi-segment dynamic routes like "resumes/user123/en":
/// - `resolution.param('param_0')` returns "user123"
/// - `resolution.param('param_1')` returns "en"
/// - `resolution.last_segment` returns "en"
class RouteResolutionV2 {
  /// The resolved [AppScreenV2] (may be a dynamically created clone).
  final AppScreenV2 screen;

  /// Index in the app_screens_v2 list.
  ///
  /// Returns -1 if the route was not found.
  final int index;

  /// Whether this resolution created a new dynamic screen.
  ///
  /// True when the route matched a base route and was cloned
  /// (e.g., "event/abc123" matched base route "event").
  final bool was_dynamically_created;

  /// The base route that was matched.
  ///
  /// For "event/abc123", this would be "event".
  /// For static routes like "home", this equals [full_path].
  final String base_route;

  /// Extracted path parameters.
  ///
  /// For single dynamic segments: `{"id": "abc123"}`
  /// For multiple segments: `{"param_0": "abc123", "param_1": "en"}`
  final Map<String, String> params;

  /// The full resolved path.
  ///
  /// This is the normalized route name (without leading slash).
  final String full_path;

  /// Whether resolution was successful.
  ///
  /// False when the route could not be matched to any registered screen.
  final bool is_valid;

  /// Creates a new [RouteResolutionV2].
  const RouteResolutionV2({
    required this.screen,
    required this.index,
    required this.was_dynamically_created,
    required this.base_route,
    required this.params,
    required this.full_path,
    required this.is_valid,
  });

  /// Factory for failed resolution.
  ///
  /// Use this when a route cannot be resolved.
  factory RouteResolutionV2.notFound(String attempted_route) {
    return RouteResolutionV2(
      screen: AppScreenV2.empty(),
      index: -1,
      was_dynamically_created: false,
      base_route: "",
      params: const {},
      full_path: attempted_route,
      is_valid: false,
    );
  }

  /// Get a specific parameter by key.
  ///
  /// Returns null if the parameter doesn't exist.
  ///
  /// ```dart
  /// final event_id = resolution.param('id');
  /// final lang = resolution.param('param_1');
  /// ```
  String? param(String key) => params[key];

  /// Get the last path segment (common use case for IDs).
  ///
  /// For "event/abc123", returns "abc123".
  /// For "resumes/user/en", returns "en".
  String get last_segment {
    final uri = Uri.parse(full_path);
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "";
  }

  /// Whether this is a dynamic route (has parameters).
  bool get is_dynamic => was_dynamically_created || params.isNotEmpty;

  /// The number of path segments in the full path.
  int get segment_count => Uri.parse(full_path).pathSegments.length;

  @override
  String toString() {
    return 'RouteResolutionV2('
        'is_valid: $is_valid, '
        'full_path: "$full_path", '
        'base_route: "$base_route", '
        'params: $params, '
        'dynamic: $was_dynamically_created)';
  }
}
