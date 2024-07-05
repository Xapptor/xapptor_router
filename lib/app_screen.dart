// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_router/swipe_gesture_detector/swipe_gesture_detector.dart';

class AppScreen extends StatefulWidget {
  String name;
  String path;
  int check_app_path_timer;
  Widget child;

  AppScreen({
    super.key,
    required this.name,
    this.path = "",
    this.check_app_path_timer = 6000,
    required this.child,
  });

  AppScreen clone() {
    return AppScreen(
      name: name,
      child: child,
    );
  }

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  check_app_path() {
    if (widget.path.contains("payment_success")) {
      bool is_success = widget.path.contains("true");
      String success_message = is_success ? "Payment Successful" : "Payment Failed";

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            success_message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: Icon(
            is_success ? Icons.check_circle_rounded : Icons.info,
            color: Colors.white,
          ),
          backgroundColor: is_success ? Colors.green : Colors.red,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );

      Timer(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: widget.check_app_path_timer), () {
      check_app_path();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwipeGestureDetectorForWeb(
      child: widget.child,
    );
  }
}
