// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/foundation.dart';

enum ArrowDirection {
  top,
  bottom,
  left,
  right,
}

call_threshold_action({
  required ArrowDirection arrow_direction,
  required Function? top_swipe_callback,
  required Function? custom_bottom_swipe_callback,
  required Function? left_swipe_callback,
  required Function? right_swipe_callback,
  required ValueNotifier<bool> can_go_back,
  required ValueNotifier<bool> can_go_forward,
}) {
  switch (arrow_direction) {
    case ArrowDirection.top:
      if (top_swipe_callback != null) {
        top_swipe_callback();
      } else {
        _reload();
      }
      break;
    case ArrowDirection.bottom:
      if (custom_bottom_swipe_callback != null) {
        custom_bottom_swipe_callback();
      }
      break;
    case ArrowDirection.left:
      if (can_go_back.value) {
        if (left_swipe_callback != null) {
          left_swipe_callback();
        } else {
          can_go_back.value = _can_go_back();
        }
      }
      break;
    case ArrowDirection.right:
      if (can_go_forward.value) {
        if (right_swipe_callback != null) {
          right_swipe_callback();
        } else {
          can_go_forward.value = _can_go_forward();
        }
      }
      break;
  }
}

_reload() {
  html.window.location.reload();
}

bool _can_go_back() {
  html.window.history.back();
  return false;
}

bool _can_go_forward() {
  html.window.history.forward();
  return false;
}
