import 'package:xapptor_router/V2/app_screens_v2.dart';
import 'package:xapptor_router/V2/route_resolution.dart';
import 'package:xapptor_router/V2/route_resolver.dart';

/// Gets the last path segment from the currently active screen.
///
/// This is the simplest way to extract an ID from a dynamic route.
///
/// ## Example
///
/// If the current route is "event/abc123":
///
/// ```dart
/// final event_id = get_last_path_segment_v2();
/// print(event_id);  // "abc123"
/// ```
///
/// If the current route is "resumes/user123/en":
///
/// ```dart
/// final lang = get_last_path_segment_v2();
/// print(lang);  // "en"
/// ```
///
/// ## Returns
///
/// The last segment of the current route path, or empty string if none.
String get_last_path_segment_v2() {
  if (app_screens_v2.isEmpty) return "";

  final current_screen_name = app_screens_v2.last.name;
  final uri = Uri.parse(current_screen_name);

  return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "";
}

/// Gets the full route resolution for the currently active screen.
///
/// This provides access to all route metadata and parameters.
///
/// ## Example
///
/// ```dart
/// final resolution = get_current_route_resolution_v2();
///
/// if (resolution != null) {
///   print("Route: ${resolution.full_path}");
///   print("Base: ${resolution.base_route}");
///   print("ID: ${resolution.param('id')}");
///   print("Dynamic: ${resolution.was_dynamically_created}");
/// }
/// ```
///
/// ## For Multi-Segment Parameters
///
/// ```dart
/// // Route: "resumes/user123/en"
/// final resolution = get_current_route_resolution_v2();
/// final user_id = resolution?.param('param_0');  // "user123"
/// final lang = resolution?.param('param_1');     // "en"
/// ```
///
/// ## Returns
///
/// A [RouteResolutionV2] for the current screen, or null if no screens
/// are registered.
RouteResolutionV2? get_current_route_resolution_v2() {
  if (app_screens_v2.isEmpty) return null;

  final current_screen_name = app_screens_v2.last.name;
  return RouteResolverV2.resolve(current_screen_name);
}

/// Checks if the current route is a dynamic route.
///
/// A dynamic route is one that was created by cloning a base route
/// (e.g., "event/abc123" from base "event").
///
/// ## Example
///
/// ```dart
/// if (is_current_route_dynamic_v2()) {
///   final id = get_last_path_segment_v2();
///   // Load data for this specific ID
/// }
/// ```
bool is_current_route_dynamic_v2() {
  final resolution = get_current_route_resolution_v2();
  return resolution?.was_dynamically_created ?? false;
}

/// Gets the base route of the current screen.
///
/// For "event/abc123", returns "event".
/// For "home", returns "home".
///
/// ## Example
///
/// ```dart
/// final base = get_current_base_route_v2();
/// print(base);  // "event"
/// ```
String get_current_base_route_v2() {
  final resolution = get_current_route_resolution_v2();
  return resolution?.base_route ?? "";
}

/// Gets all parameters from the current route.
///
/// ## Example
///
/// ```dart
/// // Route: "resumes/user123/en"
/// final params = get_current_route_params_v2();
/// // {"param_0": "user123", "param_1": "en"}
///
/// // Route: "event/abc123"
/// final params = get_current_route_params_v2();
/// // {"id": "abc123"}
/// ```
Map<String, String> get_current_route_params_v2() {
  final resolution = get_current_route_resolution_v2();
  return resolution?.params ?? {};
}
