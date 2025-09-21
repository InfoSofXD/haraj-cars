import 'package:flutter/material.dart';

class ResponsiveUI extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveUI({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 650;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < 1280 &&
        MediaQuery.of(context).size.width >= 650;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1280;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width >= 1280) {
      return desktop;
    } else if (size.width >= 650) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
