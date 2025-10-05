import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorUtils {
  // --- Color space helpers (sRGB <-> linear) ---
  static double _srgbToLinear(double c) {
    // c in [0,1]
    if (c <= 0.04045) return c / 12.92;
    return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _linearToSrgb(double c) {
    // c in [0,1]
    if (c <= 0.0031308) return 12.92 * c;
    return 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;
  }

  static List<double> _colorToLinearRgb(Color color) {
    final r = _srgbToLinear(color.r / 255.0);
    final g = _srgbToLinear(color.g / 255.0);
    final b = _srgbToLinear(color.b / 255.0);
    return [r, g, b];
  }

  static Color _linearRgbToColor(double r, double g, double b) {
    int to8bit(double v) => (v.clamp(0.0, 1.0) * 255.0).round();
    final sr = _linearToSrgb(r);
    final sg = _linearToSrgb(g);
    final sb = _linearToSrgb(b);
    return Color.fromARGB(255, to8bit(sr), to8bit(sg), to8bit(sb));
  }

  /// Relative luminance from linear RGB
  static double luminanceLinear(Color color) {
    final rgb = _colorToLinearRgb(color);
    // Rec. 709 coefficients
    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2];
  }

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

  /// Blend in linear color space, then return sRGB color
  static Color blendColorsLinear(Color base, Color overlay, double alpha) {
    final a = alpha.clamp(0.0, 1.0);
    final bl = _colorToLinearRgb(base);
    final ol = _colorToLinearRgb(overlay);
    final rl = bl[0] * (1 - a) + ol[0] * a;
    final gl = bl[1] * (1 - a) + ol[1] * a;
    final blc = bl[2] * (1 - a) + ol[2] * a;
    return _linearRgbToColor(rl, gl, blc);
  }

  /// Calculate symmetric per-channel squared error
  static double calculateAsymmetricError(Color original, Color approximation) {
    final double dr = (original.r.toDouble() - approximation.r.toDouble());
    final double dg = (original.g.toDouble() - approximation.g.toDouble());
    final double db = (original.b.toDouble() - approximation.b.toDouble());

    return dr * dr + dg * dg + db * db;
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