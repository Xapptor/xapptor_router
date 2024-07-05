import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/check_threshold.dart';

Widget swipe_gesture_detector_icon({
  required IconData icon_data,
  required double container_size,
  required double icon_size,
  required ArrowDirection arrow_direction,
  required bool spacer_at_leading,
}) {
  return Container(
    width: container_size,
    height: container_size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withOpacity(0.5),
    ),
    child: Flex(
      direction: arrow_direction == ArrowDirection.top || arrow_direction == ArrowDirection.bottom
          ? Axis.vertical
          : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (spacer_at_leading) const Spacer(flex: 1),
        Expanded(
          flex: 1,
          child: Icon(
            icon_data,
            color: Colors.white,
            size: icon_size,
          ),
        ),
        if (!spacer_at_leading) const Spacer(flex: 1),
      ],
    ),
  );
}
