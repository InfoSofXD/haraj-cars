// gradients.dart
import 'package:flutter/material.dart';

// Light Gradient
class LightGradient {
  static const LinearGradient main = LinearGradient(
    colors: [
      Color(0xFF203D31),
      Color(0xFF26725A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Dark Gradient
class DarkGradient {
  static const LinearGradient main = LinearGradient(
    colors: [
      Color(0xFF353535),
      Color(0xFF424242),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Disable Gradient
class DisableGradient {
  static LinearGradient main = LinearGradient(
    colors: [
      Colors.grey.shade700,
      Colors.grey.shade400,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Disable Gradient
class MaxGradient {
  static LinearGradient main = LinearGradient(
    colors: [
      Colors.red.shade700,
      Colors.red.shade400,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
