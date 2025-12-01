# xapptor_router V2 - Migration Guide

This guide helps you migrate from xapptor_router V1 to V2, which includes the new `RouteResolver` system for unified route handling.

## What's New in V2

### 1. Dynamic Route Support in `open_screen_v2`

The biggest improvement: `open_screen_v2` now supports dynamic routes!

```dart
// V1 - Doesn't work with dynamic routes
open_screen("event/abc123");  // ❌ Fails - exact match only

// V1 - Web-only workaround
html.window.location.href = "https://example.com/event/abc123";  // ❌ Web only, page reload

// V2 - Works everywhere!
open_screen_v2("event/abc123");  // ✅ Works on web, mobile, desktop
```

### 2. Route Resolution API

Access route parameters easily:

```dart
// Simple: Get last segment (ID)
final event_id = get_last_path_segment_v2();

// Advanced: Get full resolution
final resolution = get_current_route_resolution_v2();
final event_id = resolution?.param('id');
final base_route = resolution?.base_route;
```

### 3. Error Handling

```dart
open_screen_v2(
  "unknown/route",
  on_not_found: (route, error) {
    showSnackBar("Page not found");
  },
  fallback_route: "home",  // Navigate here if not found
);
```

### 4. Global Callbacks

```dart
// In main.dart
RouteResolverV2.on_route_not_found = (route, error) {
  analytics.logEvent('route_not_found', {'route': route});
};

RouteResolverV2.on_route_resolved = (resolution) {
  analytics.logScreenView(resolution.full_path);
};
```

## Migration Steps

### Step 1: Update Imports

```dart
// Before (V1)
import 'package:xapptor_router/app.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_router/get_last_path_segment.dart';
import 'package:xapptor_router/initial_values_routing.dart';

// After (V2)
import 'package:xapptor_router/V2/app_v2.dart';
import 'package:xapptor_router/V2/app_screen_v2.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';
import 'package:xapptor_router/V2/get_last_path_segment_v2.dart';
import 'package:xapptor_router/V2/initial_values_routing_v2.dart';
```

### Step 2: Update Class/Function Names

| V1 | V2 |
|----|-----|
| `App` | `AppV2` |
| `AppScreen` | `AppScreenV2` |
| `add_new_app_screen` | `add_new_app_screen_v2` |
| `open_screen` | `open_screen_v2` |
| `search_screen` | `search_screen_v2` |
| `remove_screen` | `remove_screen_v2` |
| `get_last_path_segment` | `get_last_path_segment_v2` |
| `landing_screen` | `landing_screen_v2` |
| `unknown_screen` | `unknown_screen_v2` |
| `current_build_mode` | `current_build_mode_v2` |
| `BuildMode` | `BuildModeV2` |
| `open_login` | `open_login_v2` |
| `open_register` | `open_register_v2` |
| `open_restore_password` | `open_restore_password_v2` |

### Step 3: Update main.dart

```dart
// Before (V1)
import 'package:xapptor_router/app.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_router/initial_values_routing.dart';

void main() {
  // ... initialization ...

  current_build_mode = BuildMode.release;

  landing_screen = AppScreen(
    name: "landing",
    child: LandingScreen(),
  );

  add_new_app_screen(
    AppScreen(
      name: "home",
      child: HomeScreen(),
    ),
  );

  runApp(
    App(
      app_name: "My App",
      theme: myTheme,
    ),
  );
}

// After (V2)
import 'package:xapptor_router/V2/app_v2.dart';
import 'package:xapptor_router/V2/app_screen_v2.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';
import 'package:xapptor_router/V2/initial_values_routing_v2.dart';

void main() {
  // ... initialization ...

  current_build_mode_v2 = BuildModeV2.release;

  landing_screen_v2 = AppScreenV2(
    name: "landing",
    child: LandingScreen(),
  );

  add_new_app_screen_v2(
    AppScreenV2(
      name: "home",
      child: HomeScreen(),
    ),
  );

  runApp(
    AppV2(
      app_name: "My App",
      theme: myTheme,
    ),
  );
}
```

### Step 4: Replace Web-Only Navigation

```dart
// Before (V1) - Web only!
import 'dart:html' as html;

void navigateToEvent(String event_id) {
  html.window.location.href = "https://example.com/event/$event_id";
}

// After (V2) - Cross-platform!
void navigateToEvent(String event_id) {
  open_screen_v2("event/$event_id");
}
```

### Step 5: Update Parameter Access (Optional)

```dart
// Before (V1)
event_id = get_last_path_segment();

// After (V2) - Same syntax works!
event_id = get_last_path_segment_v2();

// Or use the new advanced API
final resolution = get_current_route_resolution_v2();
event_id = resolution?.param('id') ?? "";
```

## New Features to Explore

### Route Validation

```dart
if (RouteResolverV2.can_resolve("admin/dashboard")) {
  showAdminButton();
}
```

### Route Statistics

```dart
final stats = RouteResolverV2.get_stats();
print("Total screens: ${stats['total']}");
print("Static: ${stats['static']}");
print("Dynamic: ${stats['dynamic']}");
```

### Memory Management

```dart
// Clean up unused dynamic screens
RouteResolverV2.cleanup_dynamic_screens(except_route: current_route);
```

### Helper Functions

```dart
// Check if current route is dynamic
if (is_current_route_dynamic_v2()) {
  loadDynamicContent();
}

// Get base route
final base = get_current_base_route_v2();  // "event" for "event/abc123"

// Get all parameters
final params = get_current_route_params_v2();  // {"id": "abc123"}
```

## Common Issues

### Issue: Screen not found after migration

Make sure you're using `AppScreenV2` and `add_new_app_screen_v2`:

```dart
// Wrong
add_new_app_screen(AppScreen(name: "home", child: Home()));

// Correct
add_new_app_screen_v2(AppScreenV2(name: "home", child: Home()));
```

### Issue: Dynamic routes not working

Ensure the base route is registered:

```dart
// Register base route
add_new_app_screen_v2(
  AppScreenV2(
    name: "event",  // Base route
    child: EventView(),
  ),
);

// Then this works:
open_screen_v2("event/abc123");
```

### Issue: `html` import errors on mobile

Remove the `dart:html` import and use `open_screen_v2`:

```dart
// Remove this
import 'dart:html' as html;

// Replace this
html.window.location.href = "url";

// With this
open_screen_v2("route/path");
```

## Backwards Compatibility

V1 code continues to work. You can migrate incrementally:

1. Keep V1 code running
2. Add V2 imports alongside V1
3. Migrate one screen at a time
4. Remove V1 imports when done

## File Structure

```
xapptor_router/lib/
├── V1/                              # Legacy code (preserved)
│   ├── app.dart
│   ├── app_screen.dart
│   ├── app_screens.dart
│   └── ...
├── V2/                              # New V2 implementation
│   ├── app_v2.dart
│   ├── app_screen_v2.dart
│   ├── app_screens_v2.dart
│   ├── route_resolver.dart          # NEW: Central resolver
│   ├── route_resolution.dart        # NEW: Resolution result
│   ├── get_last_path_segment_v2.dart
│   └── README.md                    # This file
└── ... (shared utilities)
```

## Questions?

If you have questions about the migration, check the dartdoc comments in the V2 files - they include extensive examples and usage notes.
