import 'dart:async';

import 'package:flutter/material.dart';

// AppScreen model.

class AppScreen extends StatefulWidget {
  AppScreen({
    required this.name,
    required this.child,
    this.app_path = "",
  });

  final String name;
  final Widget child;
  String app_path;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  check_app_path() {
    //print("check_app_path " + widget.app_path);

    if (widget.app_path.contains("payment_success")) {
      bool is_success = widget.app_path.contains("true");
      String success_message =
          is_success ? "Payment Successful" : "Payment Failed";

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            success_message,
            style: TextStyle(
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

      Timer(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    check_app_path();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
