// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

update_path(String new_path) {
  html.window.history.pushState(null, 'home', new_path);
}
