import 'package:flutter/material.dart';
import 'app_screen_route_information_parser.dart';
import 'app_screen_router_delegate.dart';

// App widget.

class App extends StatelessWidget {
  const App({
    required this.app_name,
    required this.theme,
  });

  final String app_name;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    AppScreenRouterDelegate router_delegate = AppScreenRouterDelegate();
    AppScreenRouteInformationParser route_information_parser =
        AppScreenRouteInformationParser();

    MaterialApp material_app = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: app_name,
      theme: theme,
      routerDelegate: router_delegate,
      routeInformationParser: route_information_parser,
    );

    print("Initial route = ${material_app.initialRoute}");
    return material_app;
  }
}
