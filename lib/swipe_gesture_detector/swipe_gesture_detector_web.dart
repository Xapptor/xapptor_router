import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/get_swipe_gesture_detector_icon_model.dart';
import 'package:xapptor_router/swipe_gesture_detector/call_threshold_action.dart';
import 'package:xapptor_router/swipe_gesture_detector/enable_swipe_gesture_detector_listener.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector_icon.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector_icon_model.dart';

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

  final List<Offset> _scroll_deltas = [];

  @override
  void initState() {
    super.initState();
    enable_swipe_gesture_detector_listener();
    window_event_listener();
  }

  @override
  void dispose() {
    _inactivity_timer?.cancel();
    _periodic_timer?.cancel();
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

  final Duration _inactivity_duration = const Duration(milliseconds: 500);

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

  final scrollController = ScrollController();

  ValueNotifier<ArrowDirection> arrow_direction = ValueNotifier<ArrowDirection>(ArrowDirection.left);

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

    x_position = x_position.clamp(-container_size, -half_container_size);
    y_position = y_position.clamp(-container_size, -half_container_size);

    bool threshold_reached = x_position == -half_container_size || y_position == -half_container_size;

    if (threshold_reached) {
      _scroll_deltas.clear();

      call_threshold_action(
        arrow_direction: arrow_direction.value,
        top_swipe_callback: widget.top_swipe_callback,
        custom_bottom_swipe_callback: widget.custom_bottom_swipe_callback,
        left_swipe_callback: widget.left_swipe_callback,
        right_swipe_callback: widget.right_swipe_callback,
        //
        can_go_back: can_go_back,
        can_go_forward: can_go_forward,
      );
    }

    SwipeGestureDetectorIconModel icon_model = get_swipe_gesture_detector_icon_model(
      scroll_deltas: _scroll_deltas,
      screen_height: screen_height,
      screen_width: screen_width,
      container_size: container_size,
      x_position: x_position,
      y_position: y_position,
      total_x_scroll: total_x_scroll,
      total_y_scroll: total_y_scroll,
      half_container_size: half_container_size,
      arrow_direction: arrow_direction,
    );

    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (listener_enabled.value) {
          _pointer_scroll_event(event as PointerScrollEvent);
        }
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            left: icon_model.left,
            right: icon_model.right,
            top: icon_model.top,
            bottom: icon_model.bottom,
            child: swipe_gesture_detector_icon(
              icon_data: icon_model.icon_data,
              container_size: container_size,
              icon_size: icon_size,
              arrow_direction: arrow_direction.value,
              spacer_at_leading: icon_model.spacer_at_leading,
            ),
          ),
        ],
      ),
    );
  }
}
