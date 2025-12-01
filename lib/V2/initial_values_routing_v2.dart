import 'package:flutter/material.dart';
import 'package:xapptor_router/V2/app_screen_v2.dart';

/// Callback function for handling app screen opening.
///
/// Set by [AppScreenRouterDelegateV2] during initialization.
/// Called by [open_screen_v2] to trigger navigation.
Function handle_app_screen_opening_v2 = (int index) {};

/// The landing screen shown when navigating to '/'.
///
/// Set this before running the app:
///
/// ```dart
/// landing_screen_v2 = AppScreenV2(
///   name: "landing",
///   child: LandingScreen(),
/// );
/// ```
AppScreenV2 landing_screen_v2 = AppScreenV2(
  name: "landing",
  child: const SizedBox(),
);

/// The screen shown for unknown/404 routes.
///
/// Set this before running the app:
///
/// ```dart
/// unknown_screen_v2 = AppScreenV2(
///   name: "unknown_screen",
///   child: NotFoundScreen(),
/// );
/// ```
AppScreenV2 unknown_screen_v2 = AppScreenV2(
  name: "unknown_screen",
  child: const SizedBox(),
);

/// Current build mode for the application.
///
/// Affects logging, error handling, and other debug features.
BuildModeV2 current_build_mode_v2 = BuildModeV2.develop;

/// Build modes for the application.
///
/// - [release]: Production mode with minimal logging
/// - [develop]: Development mode with verbose logging
enum BuildModeV2 {
  /// Production mode.
  release,

  /// Development mode.
  develop,
}
