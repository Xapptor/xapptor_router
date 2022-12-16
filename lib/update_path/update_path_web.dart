import 'dart:html' as html;

update_path(String new_path) {
  print('update_path: $new_path');
  html.window.history.pushState(null, 'home', new_path);
}
