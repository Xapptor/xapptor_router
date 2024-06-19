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

class _AppState extends State<App> {
  SharedPreferences? prefs;

  void _toggle_theme({
    required ThemeMode new_theme_mode,
  }) {
    theme_mode = new_theme_mode;
    setState(() {});
  }

  _check_theme_mode() async {
    prefs = await SharedPreferences.getInstance();
    theme_mode = (prefs!.getString("theme_mode") ?? "light") == "light" ? ThemeMode.light : ThemeMode.dark;
    setState(() {});
  }

  @override
  void initState() {
    toggle_app_theme = _toggle_theme;
    super.initState();
    _check_theme_mode();
  }

  @override
  Widget build(BuildContext context) {
    AppScreenRouterDelegate router_delegate = AppScreenRouterDelegate();
    AppScreenRouteInformationParser route_information_parser = AppScreenRouteInformationParser();

    MaterialApp material_app = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: widget.app_name,
      theme: widget.theme,
      darkTheme: widget.dark_theme,
      themeMode: theme_mode,
      routerDelegate: router_delegate,
      routeInformationParser: route_information_parser,
    );

    debugPrint("Initial route = ${material_app.initialRoute}");
    return material_app;
  }
}
