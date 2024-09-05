import 'package:flutter/material.dart';
import 'package:xapptor_router/app_screen.dart';

// Initial values for app router delegate.

Function handle_app_screen_opening = () {};

AppScreen landing_screen = AppScreen(
  name: "landing",
  child: const SizedBox(),
);

AppScreen unknown_screen = AppScreen(
  name: "unknown_screen",
  child: const SizedBox(),
);

BuildMode current_build_mode = BuildMode.develop;

enum BuildMode {
  release,
  develop,
}
