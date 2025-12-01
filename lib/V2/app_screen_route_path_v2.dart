/// Represents the current route path state for navigation.
///
/// Used internally by [AppScreenRouterDelegateV2] and
/// [AppScreenRouteInformationParserV2] to manage navigation state.
///
/// ## Route States
///
/// - **Landing**: The root '/' route
/// - **Details**: A named route like '/home' or '/event/abc123'
/// - **Unknown**: A 404/not-found route
///
/// ## Example
///
/// ```dart
/// final path = AppScreenRoutePathV2.details("event/abc123");
/// print(path.is_details_page);  // true
/// print(path.name);             // "event/abc123"
/// ```
class AppScreenRoutePathV2 {
  /// The route name (null for landing/unknown).
  final String? name;

  /// Whether this is an unknown/404 route.
  final bool is_unknown;

  /// Creates a landing page route path (for '/').
  AppScreenRoutePathV2.landing()
      : name = null,
        is_unknown = false;

  /// Creates a details page route path.
  ///
  /// [name] is the route name (e.g., "home", "event/abc123").
  AppScreenRoutePathV2.details(this.name) : is_unknown = false;

  /// Creates an unknown/404 route path.
  AppScreenRoutePathV2.unknown()
      : name = null,
        is_unknown = true;

  /// Whether this is the landing page (root '/').
  bool get is_landing_page => name == null && !is_unknown;

  /// Whether this is a details page (named route).
  bool get is_details_page => name != null;

  @override
  String toString() {
    if (is_unknown) return 'AppScreenRoutePathV2.unknown()';
    if (is_landing_page) return 'AppScreenRoutePathV2.landing()';
    return 'AppScreenRoutePathV2.details("$name")';
  }
}
