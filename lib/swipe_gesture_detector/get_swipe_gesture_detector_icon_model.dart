import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/call_threshold_action.dart';
import 'package:xapptor_router/swipe_gesture_detector/enable_swipe_gesture_detector_listener.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector_icon_model.dart';

SwipeGestureDetectorIconModel get_swipe_gesture_detector_icon_model({
  required List<Offset> scroll_deltas,
  required double screen_height,
  required double screen_width,
  required double container_size,
  required double x_position,
  required double y_position,
  required double total_x_scroll,
  required double total_y_scroll,
  required double half_container_size,
  required ValueNotifier<ArrowDirection> arrow_direction,
}) {
  IconData icon_data = Icons.arrow_back;

  bool spacer_at_leading = true;

  double center_x = (screen_width / 2) - (container_size / 2);
  double center_y = (screen_height / 2) - (container_size / 2);

  double? left = x_position;
  double? right;
  double? top = center_y;
  double? bottom;

  if (total_x_scroll.abs() > total_y_scroll.abs()) {
    if (total_x_scroll < 0) {
      //
      arrow_direction.value = ArrowDirection.left;
      icon_data = Icons.arrow_back;
      //
      left = x_position;
      right = null;
      top = center_y;
      bottom = null;
      //
    } else if (total_x_scroll > 0) {
      //
      arrow_direction.value = ArrowDirection.right;
      icon_data = Icons.arrow_forward;
      spacer_at_leading = false;
      //
      left = null;
      right = x_position;
      top = center_y;
      bottom = null;
      //
    }
  } else {
    if (total_y_scroll < 0) {
      //
      arrow_direction.value = ArrowDirection.top;
      icon_data = Icons.arrow_upward;
      //
      left = center_x;
      right = null;
      top = y_position;
      bottom = null;
      //
    } else if (total_y_scroll > 0) {
      //
      arrow_direction.value = ArrowDirection.bottom;
      icon_data = Icons.arrow_downward;
      spacer_at_leading = false;
      //
      left = center_x;
      right = null;
      top = null;
      bottom = y_position;
      //
    }
  }

  if (!can_go_back.value || !can_go_forward.value) {
    if (arrow_direction.value == ArrowDirection.left) {
      left = can_go_back.value ? x_position : -container_size;
      right = null;
      top = center_y;
      bottom = null;
    } else if (arrow_direction.value == ArrowDirection.right) {
      left = null;
      right = can_go_forward.value ? x_position : -container_size;
      top = center_y;
      bottom = null;
    }
  }

  if (scroll_deltas.isEmpty) {
    x_position = -container_size;

    left = x_position;
    right = null;
    top = center_y;
    bottom = null;
  }

  return SwipeGestureDetectorIconModel(
    icon_data: icon_data,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    spacer_at_leading: spacer_at_leading,
  );
}
