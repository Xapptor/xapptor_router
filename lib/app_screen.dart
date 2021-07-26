import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  AppScreen({
    required this.name,
    required this.child,
  });

  final String name;
  final Widget child;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
