import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  /// Blend two colors with alpha transparency
  static Color blendColors(Color base, Color overlay, double alpha) {
    final a = alpha.clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (base.r * (1 - a) + overlay.r * a).round(),
      (base.g * (1 - a) + overlay.g * a).round(),
      (base.b * (1 - a) + overlay.b * a).round(),
    );
  }

  /// Calculate asymmetric error (only penalize when approximation is lighter)
  static double calculateAsymmetricError(Color original, Color approximation) {
    double errorR = max(0.0, original.r - approximation.r.toDouble());
    double errorG = max(0.0, original.g - approximation.g.toDouble());
    double errorB = max(0.0, original.b - approximation.b.toDouble());
    
    return errorR * errorR + errorG * errorG + errorB * errorB;
  }

  /// Convert image pixel to Color
  static Color pixelToColor(int pixel) {
    return Color.fromARGB(
      255,
      (pixel >> 16) & 0xFF,
      (pixel >> 8) & 0xFF,
      pixel & 0xFF,
    );
  }

  /// Convert Color to image pixel
  static int colorToPixel(Color color) {
    return (255 << 24) | (color.r.toInt() << 16) | (color.g.toInt() << 8) | color.b.toInt();
  }
}