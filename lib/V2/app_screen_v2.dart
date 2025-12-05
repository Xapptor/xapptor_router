// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector.dart';

/// A navigable screen in the xapptor_router V2 system.
///
/// [AppScreenV2] wraps a child widget and provides routing metadata
/// including the route name, full path, and configuration options.
///
/// ## Basic Usage
///
/// ```dart
/// add_new_app_screen_v2(
///   AppScreenV2(
///     name: "home",
///     child: HomeScreen(),
///   ),
/// );
/// ```
///
/// ## Dynamic Routes
///
/// For routes that support dynamic segments (like "event/:id"),
/// register the base route:
///
/// ```dart
/// add_new_app_screen_v2(
///   AppScreenV2(
///     name: "event",  // Base route
///     child: EventView(),
///   ),
/// );
///
/// // Then navigate with:
/// open_screen_v2("event/abc123");  // Creates dynamic clone
/// ```
///
/// ## Accessing Route Parameters
///
/// In your screen widget, use [get_last_path_segment_v2] or
/// [get_current_route_resolution_v2] to access route parameters.
class AppScreenV2 extends StatefulWidget {
  /// The route name for this screen.
  ///
  /// For static routes: "home", "login", "settings"
  /// For dynamic routes: The full path including parameters (e.g., "event/abc123")
  String name;

  /// The full URI path including query parameters.
  ///
  /// Set automatically during navigation.
  /// Example: "/event/abc123?ref=home"
  String path;

  /// Timer delay (in ms) before checking app path for special handling.
  ///
  /// Used for payment result detection and similar callbacks.
  int check_app_path_timer;

  /// The actual screen widget to display.
  final Widget child;

  /// Whether to enable swipe gesture detection on web (landscape only).
  bool enable_swipe_gesture_detector_for_web;

  /// Creates a new [AppScreenV2].
  ///
  /// [name] is required and must be unique across all registered screens.
  /// [child] is the widget to display when this screen is active.
  AppScreenV2({
    super.key,
    required this.name,
    this.path = "",
    this.check_app_path_timer = 6000,
    required this.child,
    this.enable_swipe_gesture_detector_for_web = false,
  });

  /// Creates an empty placeholder screen.
  ///
  /// Used internally for failed route resolutions.
  factory AppScreenV2.empty() {
    return AppScreenV2(
      name: "",
      child: const SizedBox(),
    );
  }

  /// Creates a clone of this screen with a new name and path.
  ///
  /// Used internally by [RouteResolverV2] to create dynamic route screens.
  /// The child widget reference is shared (not deep-cloned).
  ///
  /// [new_name] becomes both the name and path (with leading slash for path).
  AppScreenV2 clone_with_path(String new_name) {
    return AppScreenV2(
      name: new_name,
      path: "/$new_name",
      check_app_path_timer: check_app_path_timer,
      enable_swipe_gesture_detector_for_web: enable_swipe_gesture_detector_for_web,
      child: child,
    );
  }

  /// Legacy clone method for backwards compatibility.
  ///
  /// Prefer [clone_with_path] for explicit path setting.
  @Deprecated('Use clone_with_path instead for explicit path handling')
  AppScreenV2 clone() {
    return AppScreenV2(
      name: name,
      child: child,
    );
  }

  @override
  State<AppScreenV2> createState() => _AppScreenV2State();
}

class _AppScreenV2State extends State<AppScreenV2> {
  /// Checks the app path for special handling (e.g., payment results).
  void _check_app_path() {
    if (widget.path.contains("payment_success")) {
      bool is_success = widget.path.contains("true");
      String success_message = is_success ? "Payment Successful" : "Payment Failed";

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            success_message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: Icon(
            is_success ? Icons.check_circle_rounded : Icons.info,
            color: Colors.white,
          ),
          backgroundColor: is_success ? Colors.green : Colors.red,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );

      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: widget.check_app_path_timer), () {
      if (mounted) {
        _check_app_path();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation != Orientation.portrait && widget.enable_swipe_gesture_detector_for_web) {
      return SwipeGestureDetectorForWeb(
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }
}
