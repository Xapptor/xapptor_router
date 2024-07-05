import 'package:flutter/material.dart';

class SwipeGestureDetectorForWeb extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return child;
  }
}
