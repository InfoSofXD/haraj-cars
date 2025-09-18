// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:haraj/tools/Palette/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/initial');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light ? light : dark,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/splash/splash_icon_light.png'
                  : 'assets/splash/splash_icon_dark.png',
              width: 250,
              height: 250,
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/splash/branding.png',
              width: 50,
              height: 50,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}
