import 'package:flutter/material.dart';
import 'app_screen.dart';
import 'app_screen_route_path.dart';
import 'app_screens.dart';
import 'initial_values_routing.dart';

class AppScreenRouteInformationParser
    extends RouteInformationParser<AppScreenRoutePath> {
  @override
  Future<AppScreenRoutePath> parseRouteInformation(
      RouteInformation route_information) async {
    final uri = Uri.parse(route_information.location!);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return AppScreenRoutePath.home();
    }

    print("Complete URL: $uri");

    if (uri.pathSegments.length >= 1) {
      var name = uri.path.substring(1, uri.path.length);

      print("name placed: " + name);

      current_app_path = uri.toString();

      AppScreen app_screen = app_screens.singleWhere(
          (current_app_screen) => current_app_screen.name == name, orElse: () {
        return AppScreen(
          name: "",
          child: Container(),
        );
      });

      print("appScreen.name: " + app_screen.name);

      if (app_screen.name == "") {
        return AppScreenRoutePath.unknown();
      } else {
        return AppScreenRoutePath.details(name);
      }
    }

    // Handle unknown routes
    return AppScreenRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppScreenRoutePath path) {
    if (path.is_unknown) {
      return RouteInformation(location: '/404');
    }
    if (path.is_home_page) {
      return RouteInformation(location: '/');
    }
    if (path.is_details_page) {
      return RouteInformation(location: '/${path.name}');
    }
    return null;
  }
}
