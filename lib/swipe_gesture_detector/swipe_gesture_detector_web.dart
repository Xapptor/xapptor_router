// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/check_threshold.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector_icon.dart';

class SwipeGestureDetectorForWeb extends StatefulWidget {
  final Widget child;
  final Function? top_swipe_callback;
  final Function? custom_bottom_swipe_callback;
  final Function? left_swipe_callback;
  final Function? right_swipe_callback;

  const SwipeGestureDetectorForWeb({
    super.key,
    required this.child,
    this.top_swipe_callback,
    this.custom_bottom_swipe_callback,
    this.left_swipe_callback,
    this.right_swipe_callback,
  });

  @override
  State<SwipeGestureDetectorForWeb> createState() => _SwipeGestureDetectorForWebState();
}

class _SwipeGestureDetectorForWebState extends State<SwipeGestureDetectorForWeb> {
  Timer? _inactivity_timer;
  Timer? _periodic_timer;
  Timer? _listener_enabled_timer;

  final List<Offset> _scroll_deltas = [];

  bool listener_enabled = false;

  @override
  void initState() {
    super.initState();
    _listener_enabled_timer = Timer(const Duration(milliseconds: 1000), () {
      listener_enabled = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inactivity_timer?.cancel();
    _periodic_timer?.cancel();
    _listener_enabled_timer?.cancel();
    super.dispose();
  }

  _pointer_scroll_event(PointerScrollEvent event) {
    _scroll_deltas.add(event.scrollDelta);
    setState(() {});
    _reset_inactivity_timer();
    if (_scroll_deltas.length > 30) {
      _scroll_deltas.removeAt(0);
    }
  }

  final Duration _inactivity_duration = const Duration(milliseconds: 600);

  _reset_inactivity_timer() {
    _inactivity_timer?.cancel();
    _inactivity_timer = Timer(_inactivity_duration, _handle_inactivity);
  }

  _handle_inactivity() {
    _periodic_timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_scroll_deltas.isNotEmpty) {
        _scroll_deltas.removeAt(0);
        if (_scroll_deltas.isNotEmpty) {
          _scroll_deltas.removeAt(0);
        }

        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  ArrowDirection arrow_direction = ArrowDirection.left;

  ValueNotifier<bool> can_go_back = ValueNotifier<bool>(true);
  ValueNotifier<bool> can_go_forward = ValueNotifier<bool>(true);

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    double total_x_scroll = _scroll_deltas.fold(0, (previous_value, element) => previous_value + element.dx);
    double total_y_scroll = _scroll_deltas.fold(0, (previous_value, element) => previous_value + element.dy);

    double container_size = 100;
    double half_container_size = container_size / 2;
    double icon_size = container_size / 2;

    double total_scroll_divisor = 4;

    double x_position = (total_x_scroll / total_scroll_divisor).abs() - container_size;
    double y_position = (total_y_scroll / total_scroll_divisor).abs() - container_size;

    IconData icon_data = Icons.arrow_back;

    bool spacer_at_leading = true;

    double center_x = (screen_width / 2) - (container_size / 2);
    double center_y = (screen_height / 2) - (container_size / 2);

    double? left = x_position;
    double? right;
    double? top = center_y;
    double? bottom;

    x_position = x_position.clamp(-container_size, -half_container_size);
    y_position = y_position.clamp(-container_size, -half_container_size);

    bool threshold_reached = x_position == -half_container_size || y_position == -half_container_size;
    if (threshold_reached) {
      _scroll_deltas.clear();

      call_threshold_action(
        arrow_direction: arrow_direction,
        top_swipe_callback: widget.top_swipe_callback,
        custom_bottom_swipe_callback: widget.custom_bottom_swipe_callback,
        left_swipe_callback: widget.left_swipe_callback,
        right_swipe_callback: widget.right_swipe_callback,
        //
        can_go_back: can_go_back,
        can_go_forward: can_go_forward,
      );
    }

    if (total_x_scroll.abs() > total_y_scroll.abs()) {
      if (total_x_scroll < 0) {
        //
        arrow_direction = ArrowDirection.left;
        icon_data = Icons.arrow_back;
        //
        left = x_position;
        right = null;
        top = center_y;
        bottom = null;
        //
      } else if (total_x_scroll > 0) {
        //
        arrow_direction = ArrowDirection.right;
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
        arrow_direction = ArrowDirection.top;
        icon_data = Icons.arrow_upward;
        //
        left = center_x;
        right = null;
        top = y_position;
        bottom = null;
        //
      } else if (total_y_scroll > 0) {
        //
        arrow_direction = ArrowDirection.bottom;
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
      if (arrow_direction == ArrowDirection.left) {
        left = can_go_back.value ? x_position : -container_size;
        right = null;
        top = center_y;
        bottom = null;
      } else if (arrow_direction == ArrowDirection.right) {
        left = null;
        right = can_go_forward.value ? x_position : -container_size;
        top = center_y;
        bottom = null;
      }
    }

    if (_scroll_deltas.isEmpty) {
      x_position = -container_size;

      left = x_position;
      right = null;
      top = center_y;
      bottom = null;
    }

    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (listener_enabled) {
          _pointer_scroll_event(event as PointerScrollEvent);
        }
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            child: swipe_gesture_detector_icon(
              icon_data: icon_data,
              container_size: container_size,
              icon_size: icon_size,
              arrow_direction: arrow_direction,
              spacer_at_leading: spacer_at_leading,
            ),
          ),
        ],
      ),
    );
  }
}
