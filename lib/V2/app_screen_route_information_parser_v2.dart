import 'package:flutter/material.dart';
import 'package:xapptor_router/V2/app_screen_route_path_v2.dart';
import 'package:xapptor_router/V2/route_resolver.dart';

/// Parses URL route information and converts to [AppScreenRoutePathV2].
///
/// This class integrates with Flutter's Router and uses [RouteResolverV2]
/// for unified route resolution.
///
/// ## How It Works
///
/// 1. Flutter's Router calls [parseRouteInformation] with the current URL
/// 2. This parser uses [RouteResolverV2] to resolve the route
/// 3. If resolved, it updates the screen's path property and returns the route
/// 4. Flutter's Router then updates the navigation state
///
/// ## Example
///
/// When the browser URL changes to '/event/abc123':
///
/// 1. parseRouteInformation receives RouteInformation with path "/event/abc123"
/// 2. RouteResolverV2.resolve("event/abc123") finds the "event" base route
/// 3. A dynamic clone is created with name "event/abc123"
/// 4. AppScreenRoutePathV2.details("event/abc123") is returned
/// 5. AppScreenRouterDelegateV2 navigates to the screen
class AppScreenRouteInformationParserV2
    extends RouteInformationParser<AppScreenRoutePathV2> {
  /// Parses route information from the browser URL.
  ///
  /// Uses [RouteResolverV2] for unified route resolution, ensuring
  /// consistent behavior between URL navigation and programmatic navigation.
  @override
  Future<AppScreenRoutePathV2> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.uri.path);

    // Handle '/' (landing page)
    if (uri.pathSegments.isEmpty) {
      return AppScreenRoutePathV2.landing();
    }

    // Use RouteResolver for unified resolution
    final route_name = uri.path.substring(1); // Remove leading '/'
    final resolution = RouteResolverV2.resolve(route_name);

    if (!resolution.is_valid) {
      return AppScreenRoutePathV2.unknown();
    }

    // Update the screen's path property for query params, fragments, etc.
    resolution.screen.path = uri.toString();

    return AppScreenRoutePathV2.details(resolution.full_path);
  }

  /// Restores route information for browser URL display.
  ///
  /// Converts the current route path back to a URL for the browser.
  @override
  RouteInformation? restoreRouteInformation(AppScreenRoutePathV2 configuration) {
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

/// Shows a payment result alert dialog.
///
/// Kept for backwards compatibility with payment flow handling.
///
/// ## Parameters
///
/// - [payment_success]: Whether the payment was successful
/// - [context]: BuildContext for showing the dialog
void show_payment_result_alert_dialog_v2(
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
        actions: [
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
