// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:web/web.dart' as web;

update_path(String new_path) {
  web.window.history.pushState(null, 'home', new_path);
}
