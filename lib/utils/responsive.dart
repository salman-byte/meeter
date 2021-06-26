import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VxResponsive(
      xsmall: mobile,
      small: mobile,
      medium: tablet,
      large: desktop,
      xlarge: desktop,
      fallback: Text("Hi No layout Specified"),
    );
  }
}
