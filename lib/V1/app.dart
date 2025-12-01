import 'package:flutter/material.dart';
import 'app_screen_route_information_parser.dart';
import 'app_screen_router_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';

Function({
  required ThemeMode new_theme_mode,
}) toggle_app_theme = ({
  required ThemeMode new_theme_mode,
}) {};

ThemeMode theme_mode = ThemeMode.light;

class App extends StatefulWidget {
  final String app_name;
  final ThemeData theme;
  final ThemeData? dark_theme;

  const App({
    super.key,
    required this.app_name,
    required this.theme,
    this.dark_theme,
  });

  @override
  State<App> createState() => _AppState();
}

// Singleton router instances - survive hot reload at module level
AppScreenRouterDelegate? _router_delegate_instance;
AppScreenRouteInformationParser? _route_information_parser_instance;

AppScreenRouterDelegate get _router_delegate {
  _router_delegate_instance ??= AppScreenRouterDelegate();
  return _router_delegate_instance!;
}

AppScreenRouteInformationParser get _route_information_parser {
  _route_information_parser_instance ??= AppScreenRouteInformationParser();
  return _route_information_parser_instance!;
}

class _AppState extends State<App> {
  SharedPreferences? prefs;

  // Cache the Future to prevent re-execution on every build
  Future<String>? _theme_mode_future;

  void _toggle_theme({
    required ThemeMode new_theme_mode,
  }) {
    theme_mode = new_theme_mode;
    setState(() {});
  }

  Future<String> _check_theme_mode() async {
    prefs = await SharedPreferences.getInstance();
    String prefs_theme_mode = prefs!.getString("theme_mode") ?? "light";
    theme_mode = prefs_theme_mode == "light" ? ThemeMode.light : ThemeMode.dark;
    return prefs_theme_mode;
  }

  @override
  void initState() {
    super.initState();
    toggle_app_theme = _toggle_theme;

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
          themeMode: theme_mode,
          routerDelegate: _router_delegate,
          routeInformationParser: _route_information_parser,
        );
      },
    );
  }
}
