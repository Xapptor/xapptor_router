import 'package:flutter/material.dart';
import 'package:xapptor_router/remove_last_path_segment.dart';
import 'app_screen.dart';
import 'app_screen_route_path.dart';
import 'app_screens.dart';

// Handle URLs paths changes.

class AppScreenRouteInformationParser extends RouteInformationParser<AppScreenRoutePath> {
  @override
  Future<AppScreenRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.uri.path);

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return AppScreenRoutePath.landing();
    }

    if (uri.pathSegments.isNotEmpty) {
      var screen_name = uri.path.substring(1);

      AppScreen app_screen = search_screen(screen_name);

      app_screen.path = uri.toString();

      if (app_screen.name == "") {
        // Second search

        screen_name = remove_last_path_segment(uri);

        if (screen_name.isNotEmpty) {
          screen_name = screen_name.substring(1);
        }

        app_screen = search_screen(screen_name);

        if (app_screen.name == "") {
          return AppScreenRoutePath.unknown();
        } else {
          AppScreen new_app_screen = app_screen.clone();

          new_app_screen.name = uri.path.substring(1);
          screen_name = new_app_screen.name;
          add_new_app_screen(new_app_screen);

          return AppScreenRoutePath.details(screen_name);
        }
      } else {
        return AppScreenRoutePath.details(screen_name);
      }
    }

    // Handle unknown routes
    return AppScreenRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppScreenRoutePath configuration) {
    if (configuration.is_unknown) {
      return RouteInformation(uri: Uri.parse('/404'));
    }
    if (configuration.is_landing_page) {
      return RouteInformation(uri: Uri.parse('/'));
    }
    if (configuration.is_details_page) {
      return RouteInformation(uri: Uri.parse('/${configuration.name}'));
    }
    return null;
  }
}

show_payment_result_alert_dialog(
  bool payment_success,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          payment_success ? "Payment successful" : "Payment failed",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Accept"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
