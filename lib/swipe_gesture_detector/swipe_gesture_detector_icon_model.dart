import 'package:flutter/material.dart';

class SwipeGestureDetectorIconModel {
  final IconData icon_data;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final bool spacer_at_leading;

  SwipeGestureDetectorIconModel({
    required this.icon_data,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.spacer_at_leading,
  });
}
