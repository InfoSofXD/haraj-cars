// theme.dart
import 'package:flutter/material.dart';

// light
const MaterialColor light = MaterialColor(_lightPrimaryValue, <int, Color>{
  50: Color(0xFFE6EAF2),
  100: Color(0xFFB3C6DE),
  200: Color(0xFF809FC8),
  300: Color(0xFF4D78B2),
  400: Color(0xFF265B9F),
  500: Color(_lightPrimaryValue),
  600: Color(0xFF002460),
  700: Color(0xFF001E54),
  800: Color(0xFF001848),
  900: Color(0xFF001033),
});
const int _lightPrimaryValue = 0xFF002868;

// dark
const MaterialColor dark = MaterialColor(_darkPrimaryValue, <int, Color>{
  50: Color(0xFFF8F9F9),
  100: Color(0xFFF1F3F4),
  200: Color(0xFFE2E3E5),
  300: Color(0xFFD3D4D6),
  400: Color(0xFFC4C4C7),
  500: Color(_darkPrimaryValue),
  600: Color(0xFF3D3D3D),
  700: Color(0xFF2C2C2C),
  800: Color(0xFF1B1B1B),
  900: Color(0xFF0A0A0A),
});
const int _darkPrimaryValue = 0xFF424242;
