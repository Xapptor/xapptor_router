import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/enable_swipe_gesture_detector_listener.dart';
import 'package:xapptor_router/V2/app_screen_route_path_v2.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';
import 'package:xapptor_router/V2/initial_values_routing_v2.dart';
import 'package:xapptor_router/V2/route_resolver.dart';
import 'package:xapptor_router/V2/save_user_session_v2.dart';

/// Router delegate for xapptor_router V2.
///
/// Manages the navigation state and coordinates with Flutter's Router
/// to display the correct screens.
///
/// ## How It Works
///
/// 1. [setNewRoutePath] is called when the route changes (URL or programmatic)
/// 2. The delegate looks up the screen in [app_screens_v2]
/// 3. [build] creates a Navigator with the appropriate pages
/// 4. [onDidRemovePage] handles cleanup after back navigation
///
/// ## Back Navigation
///
/// When a page is popped (via back button, gesture, or `Navigator.pop()`),
/// the [onDidRemovePage] callback is invoked to update the navigation state.
/// This uses the modern Flutter Navigator 2.0 API (Flutter 3.22+).
///
/// ## Pop Prevention
///
/// To prevent a page from being popped, use the `canPop` property on
/// [MaterialPage] or wrap your screen with [PopScope].
///
/// ## Integration
///
/// Use with [AppV2]:
///
/// ```dart
/// runApp(
///   AppV2(
///     app_name: "My App",
///     theme: myTheme,
///   ),
/// );
/// ```
class AppScreenRouterDelegateV2 extends RouterDelegate<AppScreenRoutePathV2>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppScreenRoutePathV2> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppScreenV2? _selected_app_screen;
  bool show_404 = false;
  bool _first_time = true;

  /// Flag to prevent _on_did_remove_page from processing removals during
  /// programmatic navigation. When navigating from screen A to screen B,
  /// screen A is "removed" which triggers _on_did_remove_page. Without this
  /// guard, the callback would reset _selected_app_screen to null, causing
  /// the navigator to fall back to landing instead of showing screen B.
  bool _is_navigating = false;

  /// Stores the page key being navigated away from, so we can identify
  /// when the removal callback for that specific page fires.
  String? _navigating_from_page_key;

  /// Creates a new router delegate.
  AppScreenRouterDelegateV2() : navigatorKey = GlobalKey<NavigatorState>();

  /// Gets the current route configuration.
  ///
  /// Used by Flutter's Router to determine the current state.
  @override
  AppScreenRoutePathV2 get currentConfiguration {
    if (_first_time) {
      _first_time = false;
      handle_app_screen_opening_v2 = _handle_app_screen_opening;
    }

    if (show_404) {
      return AppScreenRoutePathV2.unknown();
    }

    return _selected_app_screen == null
        ? AppScreenRoutePathV2.landing()
        : AppScreenRoutePathV2.details(_selected_app_screen!.name);
  }

  /// Builds the navigator with the current pages.
  ///
  /// Uses [onDidRemovePage] for page removal handling (Flutter 3.22+).
  /// This replaces the deprecated `onPopPage` callback and provides better
  /// integration with iOS swipe gestures and Android predictive back.
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        // Landing page is always in the stack
        MaterialPage(
          key: const ValueKey('Landing'),
          child: landing_screen_v2,
        ),
        // Show 404 or selected screen
        if (show_404)
          MaterialPage(
            key: const ValueKey('UnknownPage'),
            child: unknown_screen_v2,
          )
        else if (_selected_app_screen != null)
          MaterialPage(
            key: ValueKey(_selected_app_screen!.name),
            child: _selected_app_screen ?? const SizedBox(),
          )
      ],
      onDidRemovePage: _on_did_remove_page,
    );
  }

  /// Handles cleanup after a page is removed from the navigator.
  ///
  /// This callback is invoked when:
  /// - User taps the back button
  /// - User performs a swipe-back gesture (iOS)
  /// - User performs predictive back gesture (Android 14+)
  /// - Code calls `Navigator.pop()`
  /// - Pages list is updated declaratively
  ///
  /// Unlike the deprecated `onPopPage`, this callback:
  /// - Cannot veto pops (use [MaterialPage.canPop] instead)
  /// - Is called for both imperative and declarative removals
  /// - Only handles cleanup, not the pop decision
  ///
  /// ## Navigation Logic
  ///
  /// When a page is removed:
  /// 1. For dynamic routes (e.g., "event/abc123"): Cleanup and go to landing
  /// 2. For nested routes (e.g., "home/settings/profile"): Go to parent route
  /// 3. For simple routes (e.g., "login"): Go to landing
  void _on_did_remove_page(Page<Object?> page) {
    final page_key = page.key.toString();

    // Check if this removal is for the page we're navigating away from.
    // If so, this is expected and we should skip processing.
    if (_is_navigating && _navigating_from_page_key != null) {
      if (page_key.contains(_navigating_from_page_key!)) {
        // Reset the navigation guard now that we've handled the expected removal
        _is_navigating = false;
        _navigating_from_page_key = null;
        return;
      }
    }

    // Also skip if _is_navigating is true but page key doesn't match
    // (could be a delayed callback)
    if (_is_navigating) {
      return;
    }

    enable_swipe_gesture_detector_listener();

    _update_selected_screen_on_pop();

    show_404 = false;
    notifyListeners();
  }

  /// Updates the selected screen after a pop operation.
  ///
  /// Determines the appropriate screen to navigate to based on
  /// the current route structure.
  void _update_selected_screen_on_pop() {
    if (_selected_app_screen == null) return;

    final uri = Uri.parse(_selected_app_screen!.name);

    // Simple route (single segment like "login") - go to landing
    if (uri.pathSegments.length <= 1) {
      _selected_app_screen = null;
      return;
    }

    // Check if this is a dynamic route (contains numbers/IDs)
    final is_dynamic_with_id = _is_dynamic_route_with_id(uri);

    if (is_dynamic_with_id) {
      _cleanup_dynamic_route();
      return;
    }

    // Nested route - navigate to parent
    _navigate_to_parent_route(uri);
  }

  /// Checks if the route is a dynamic route with an ID segment.
  ///
  /// A dynamic route is one where:
  /// - It has 2 segments (e.g., "event/abc123")
  /// - The route contains numbers (indicating an ID)
  bool _is_dynamic_route_with_id(Uri uri) {
    return uri.pathSegments.length <= 2 &&
        _selected_app_screen!.name.contains(RegExp(r'[0-9]'));
  }

  /// Cleans up a dynamic route and returns to landing.
  ///
  /// Removes the dynamic screen from the registry and performs
  /// cleanup of other accumulated dynamic screens.
  void _cleanup_dynamic_route() {
    remove_screen_v2(_selected_app_screen!.name);
    RouteResolverV2.cleanup_dynamic_screens();
    _selected_app_screen = null;
  }

  /// Navigates to the parent route.
  ///
  /// For a route like "home/settings/profile", navigates to "home/settings".
  /// If the parent route doesn't exist, falls back to landing.
  void _navigate_to_parent_route(Uri uri) {
    // Remove last path segment inline
    final segments = uri.pathSegments.toList();
    if (segments.isNotEmpty) {
      segments.removeLast();
    }
    String new_path = segments.join('/');

    if (new_path.startsWith('/')) {
      new_path = new_path.substring(1);
    }

    try {
      AppScreenV2 new_screen = app_screens_v2.singleWhere(
        (app_screen) => app_screen.name == new_path,
      );

      save_user_session_v2(new_screen.name);
      _selected_app_screen = new_screen;
    } catch (e) {
      // Parent not found, go to landing
      _selected_app_screen = null;
    }
  }

  /// Sets a new route path (called by Flutter's Router).
  @override
  Future<void> setNewRoutePath(AppScreenRoutePathV2 configuration) async {
    if (configuration.is_unknown) {
      _selected_app_screen = null;
      show_404 = true;
      return;
    }

    if (configuration.is_details_page) {
      try {
        AppScreenV2 app_screen = app_screens_v2.singleWhere(
          (current_app_screen) => current_app_screen.name == configuration.name,
        );

        _selected_app_screen = app_screen;
      } catch (e) {
        // Screen not found - this shouldn't happen if RouteResolver worked
        show_404 = true;
        return;
      }
    } else {
      _selected_app_screen = null;
    }

    show_404 = false;
  }

  /// Internal handler for screen opening.
  ///
  /// Called by [open_screen_v2] to trigger navigation.
  void _handle_app_screen_opening(int index) {
    if (index >= 0 && index < app_screens_v2.length) {
      // Set navigation guard to prevent _on_did_remove_page from processing
      // the removal of the current screen during this navigation.
      _is_navigating = true;

      // Store the page key we're navigating from so we can identify
      // the removal callback for this specific page.
      _navigating_from_page_key = _selected_app_screen?.name;

      _selected_app_screen = app_screens_v2[index];
      show_404 = false;
      notifyListeners();
    }
  }
}
