import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../utils/color_utils.dart';
import '../models/thread.dart';

class ErrorCalculator {
  final img.Image originalImage;
  final img.Image originalBlurred;
  final double blurFactor;

  ErrorCalculator({
    required this.originalImage,
    required this.originalBlurred,
    required this.blurFactor,
  });

  /// Calculate error reduction for a potential line
  double calculateErrorReduction({
    required List<Offset> linePixels,
    required img.Image currentApproximation,
    required img.Image currentApproximationBlurred,
    required Thread thread,
  }) {
    double errorBefore = 0.0;
    double errorAfter = 0.0;

    for (Offset pixel in linePixels) {
      // Map to blurred coordinates
      Offset blurredPixel = Offset(
        pixel.dx / blurFactor,
        pixel.dy / blurFactor,
      );

      int bx = blurredPixel.dx.round();
      int by = blurredPixel.dy.round();

      // Boundary check
      if (bx < 0 || bx >= originalBlurred.width ||
          by < 0 || by >= originalBlurred.height) {
        continue;
      }

      // Get original and current approximation (blurred)
      final originalPixel = originalBlurred.getPixel(bx, by);
      final currentPixel = currentApproximationBlurred.getPixel(bx, by);

      final Color original = Color.fromARGB(
        255,
        originalPixel.r.toInt(),
        originalPixel.g.toInt(),
        originalPixel.b.toInt(),
      );
      final Color current = Color.fromARGB(
        255,
        currentPixel.r.toInt(),
        currentPixel.g.toInt(),
        currentPixel.b.toInt(),
      );

      // Compute luminance in linear space
      final double Lorig = ColorUtils.luminanceLinear(original);
      final double Lcurr = ColorUtils.luminanceLinear(current);

      // Error before (squared residual on luminance)
      final double residBefore = Lorig - Lcurr;
      errorBefore += residBefore * residBefore;

      // Simulate adding thread in linear space and recompute luminance
      final Color blended = ColorUtils.blendColorsLinear(
        current,
        thread.color,
        thread.opacity,
      );
      final double Lafter = ColorUtils.luminanceLinear(blended);
      final double residAfter = Lorig - Lafter;
      errorAfter += residAfter * residAfter;
    }

    return errorBefore - errorAfter;
  }
}