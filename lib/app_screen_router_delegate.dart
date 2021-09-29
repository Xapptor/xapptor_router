import 'package:flutter/material.dart';
import 'app_screen.dart';
import 'app_screen_route_path.dart';
import 'app_screens.dart';
import 'initial_values_routing.dart';

class AppScreenRouterDelegate extends RouterDelegate<AppScreenRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppScreenRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  AppScreen? _selected_app_screen;
  bool show_404 = false;

  AppScreenRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  bool first_time = true;

  AppScreenRoutePath get currentConfiguration {
    if (first_time) {
      first_time = false;
      handle_app_screen_opening = _handle_app_screen_opening;
    }

    if (show_404) {
      return AppScreenRoutePath.unknown();
    }

    return _selected_app_screen == null
        ? AppScreenRoutePath.home()
        : AppScreenRoutePath.details(_selected_app_screen!.name);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('Landing'),
          child: landing_screen,
        ),
        if (show_404)
          MaterialPage(
            key: ValueKey('UnknownPage'),
            child: unknown_screen,
          )
        else if (_selected_app_screen != null)
          MaterialPage(
            key: ValueKey(_selected_app_screen!.name),
            child: _selected_app_screen ?? Container(),
          )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        Uri uri = Uri();
        if (_selected_app_screen != null) {
          uri = Uri.parse(_selected_app_screen!.name);

          if (uri.pathSegments.length > 1) {
            int path_segments_index = int.tryParse(uri.pathSegments.last
                    .substring(uri.pathSegments.last.length - 1)) ??
                -1;

            current_app_path = uri.toString();
            //print("current_app_path $current_app_path");

            print("path: ${uri.path}");
            print("path_segments_index: $path_segments_index");

            String new_path = "";

            if (path_segments_index > 0 &&
                uri.pathSegments.last
                        .substring(uri.pathSegments.last.length - 2) ==
                    "_") {
              new_path = uri.path.substring(0, uri.path.length - 1) +
                  (path_segments_index - 1).toString();
            } else {
              int last_path_segment_index = uri.path.lastIndexOf("/");
              new_path = uri.path.substring(0, last_path_segment_index);
            }

            AppScreen new_screen = app_screens
                .singleWhere((app_screen) => app_screen.name == new_path);

            _selected_app_screen = new_screen;
          } else {
            _selected_app_screen = null;
          }
        } else {
          _selected_app_screen = null;
        }

        show_404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppScreenRoutePath path) async {
    if (path.is_unknown) {
      _selected_app_screen = null;
      show_404 = true;
      return;
    }

    if (path.is_details_page) {
      AppScreen app_screen = app_screens.singleWhere(
          (current_app_screen) => current_app_screen.name == path.name);

      _selected_app_screen = app_screen;

      current_app_path = _selected_app_screen!.name;
      print("current_app_path $current_app_path");
    } else {
      _selected_app_screen = null;
    }

    show_404 = false;
  }

  _handle_app_screen_opening(int index) {
    _selected_app_screen = app_screens[index];
    notifyListeners();
  }
}
