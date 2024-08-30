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

  Future<String> _check_theme_mode() async {
    prefs = await SharedPreferences.getInstance();
    String prefs_theme_mode = prefs!.getString("theme_mode") ?? "light";
    theme_mode = prefs_theme_mode == "light" ? ThemeMode.light : ThemeMode.dark;
    return prefs_theme_mode;
  }

  @override
  void initState() {
    toggle_app_theme = _toggle_theme;
    super.initState();
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

    return FutureBuilder<String>(
      future: _check_theme_mode(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return material_app;
            } else {
              return const Text('No data');
            }
          default:
            return const Text('No data');
        }
      },
    );
  }
}
