import 'app_screen.dart';
import 'initial_values_routing.dart';

List<AppScreen> app_screens = [];

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

remove_screen(String app_screen_name) {
  app_screens.removeWhere((app_screen) => app_screen.name == app_screen_name);
}

open_screen(String screen_name) {
  int screen_index =
      app_screens.indexWhere((app_screen) => app_screen.name == screen_name);
  handle_app_screen_opening(screen_index);
}