import 'package:flutter/material.dart';

// Initial values for app router delegate.

Function handle_app_screen_opening = () {};
Widget landing_screen = Container();
Widget unknown_screen = Container();
BuildMode current_build_mode = BuildMode.develop;

enum BuildMode {
  release,
  develop,
}
