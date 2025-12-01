import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_router/V2/app_screen_route_information_parser_v2.dart';
import 'package:xapptor_router/V2/app_screen_router_delegate_v2.dart';

/// Global function to toggle the app theme.
///
/// Set by [AppV2] during initialization.
///
/// ```dart
/// toggle_app_theme_v2(new_theme_mode: ThemeMode.dark);
/// ```
Function({required ThemeMode new_theme_mode}) toggle_app_theme_v2 = ({
  required ThemeMode new_theme_mode,
}) {};

/// Current theme mode for the application.
///
/// Updated by [toggle_app_theme_v2].
ThemeMode theme_mode_v2 = ThemeMode.light;

/// Root application widget for xapptor_router V2.
///
/// Sets up the MaterialApp.router with [AppScreenRouterDelegateV2]
/// and [AppScreenRouteInformationParserV2].
///
/// ## Usage
///
/// ```dart
/// void main() {
///   // Initialize Firebase, etc.
///
///   // Configure screens
///   landing_screen_v2 = AppScreenV2(name: "landing", child: LandingScreen());
///   unknown_screen_v2 = AppScreenV2(name: "404", child: NotFoundScreen());
///
///   add_new_app_screen_v2(AppScreenV2(name: "home", child: HomeScreen()));
///   add_new_app_screen_v2(AppScreenV2(name: "login", child: LoginScreen()));
///   add_new_app_screen_v2(AppScreenV2(name: "event", child: EventView()));
///
///   runApp(
///     AppV2(
///       app_name: "My App",
///       theme: myLightTheme,
///       dark_theme: myDarkTheme,
///     ),
///   );
/// }
/// ```
///
/// ## Theme Switching
///
/// ```dart
/// // In your settings screen:
/// toggle_app_theme_v2(new_theme_mode: ThemeMode.dark);
/// ```
class AppV2 extends StatefulWidget {
  /// The application name (shown in browser tab, etc.).
  final String app_name;

  /// The light theme data.
  final ThemeData theme;

  /// Optional dark theme data.
  final ThemeData? dark_theme;

  /// Creates a new [AppV2] instance.
  const AppV2({
    super.key,
    required this.app_name,
    required this.theme,
    this.dark_theme,
  });

  @override
  State<AppV2> createState() => _AppV2State();
}

// Singleton router instances - survive hot reload at module level
AppScreenRouterDelegateV2? _router_delegate_instance_v2;
AppScreenRouteInformationParserV2? _route_information_parser_instance_v2;

AppScreenRouterDelegateV2 get _router_delegate_v2 {
  _router_delegate_instance_v2 ??= AppScreenRouterDelegateV2();
  return _router_delegate_instance_v2!;
}

AppScreenRouteInformationParserV2 get _route_information_parser_v2 {
  _route_information_parser_instance_v2 ??= AppScreenRouteInformationParserV2();
  return _route_information_parser_instance_v2!;
}

class _AppV2State extends State<AppV2> {
  SharedPreferences? prefs;

  // Cache the Future to prevent re-execution on every build
  Future<String>? _theme_mode_future;

  void _toggle_theme({required ThemeMode new_theme_mode}) {
    theme_mode_v2 = new_theme_mode;
    setState(() {});
  }

  Future<String> _check_theme_mode() async {
    prefs = await SharedPreferences.getInstance();
    String prefs_theme_mode = prefs!.getString("theme_mode") ?? "light";
    theme_mode_v2 = prefs_theme_mode == "light" ? ThemeMode.light : ThemeMode.dark;
    return prefs_theme_mode;
  }

  @override
  void initState() {
    super.initState();
    toggle_app_theme_v2 = _toggle_theme;

    // Cache the Future so it doesn't re-execute on every build (hot reload)
    _theme_mode_future = _check_theme_mode();
  }

  @override
  Widget build(BuildContext context) {
    // Use the cached Future (created in initState) to prevent re-triggering on hot reload
    return FutureBuilder<String>(
      future: _theme_mode_future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        // Always show MaterialApp.router - don't show loading indicator
        // This prevents the router from being unmounted/remounted on hot reload
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: widget.app_name,
          theme: widget.theme,
          darkTheme: widget.dark_theme,
          themeMode: theme_mode_v2,
          routerDelegate: _router_delegate_v2,
          routeInformationParser: _route_information_parser_v2,
        );
      },
    );
  }
}
