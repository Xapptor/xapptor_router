import 'dart:async';
import 'package:flutter/foundation.dart';

ValueNotifier<bool> listener_enabled = ValueNotifier<bool>(false);
ValueNotifier<bool> can_go_back = ValueNotifier<bool>(true);
ValueNotifier<bool> can_go_forward = ValueNotifier<bool>(true);

enable_swipe_gesture_detector_listener() {
  Timer(const Duration(milliseconds: 1000), () {
    listener_enabled.value = true;
    can_go_back.value = true;
    can_go_forward.value = true;
  });
}
