import 'package:flutter/material.dart';
import 'app_screen_route_information_parser.dart';
import 'app_screen_router_delegate.dart';

class App extends StatelessWidget {
  const App({
    required this.app_name,
    required this.theme,
  });

  final String app_name;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    AppScreenRouterDelegate _router_delegate = AppScreenRouterDelegate();
    AppScreenRouteInformationParser _route_information_parser =
        AppScreenRouteInformationParser();

    final app = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: app_name,
      theme: theme,
      routerDelegate: _router_delegate,
      routeInformationParser: _route_information_parser,
    );

    print("Initial route = ${app.initialRoute}");
    return app;
  }
}
