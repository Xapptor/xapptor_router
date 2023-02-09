import 'package:flutter/widgets.dart';
import 'app_screen.dart';
import 'initial_values_routing.dart';
import 'save_user_session.dart';

// App Screens variable.

List<AppScreen> app_screens = [];

// Add new app screen.

add_new_app_screen(AppScreen new_screen) {
  app_screens.add(new_screen);

  List<AppScreen> screens = app_screens
      .where((app_screen) => app_screen.name == new_screen.name)
      .toList();

  if (screens.length > 1) {
    int duplicate_screen_index = app_screens
        .indexWhere((app_screen) => app_screen.name == new_screen.name);
    app_screens.removeAt(duplicate_screen_index);
  }
}

// Remove app screen.

remove_screen(String app_screen_name) {
  app_screens.removeWhere((app_screen) => app_screen.name == app_screen_name);
}

// Open app screen.

open_screen(String screen_name) {
  save_user_session(screen_name);

  int screen_index =
      app_screens.indexWhere((app_screen) => app_screen.name == screen_name);
  handle_app_screen_opening(screen_index);
}

open_login() => open_screen("login");
open_register() => open_screen("register");
open_restore_password() => open_screen("restore_password");

// Search app screen.

AppScreen search_screen(String screen_name) {
  return app_screens.singleWhere(
      (current_app_screen) => current_app_screen.name == screen_name,
      orElse: () {
    return AppScreen(
      name: "",
      child: Container(),
    );
  });
}
