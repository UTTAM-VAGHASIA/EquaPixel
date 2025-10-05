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

      // Get original pixel color
      final originalPixel = originalBlurred.getPixel(bx, by);
      Color original = Color.fromARGB(
        255,
        originalPixel.r.toInt(),
        originalPixel.g.toInt(),
        originalPixel.b.toInt(),
      );

      // Get current approximation
      final currentPixel = currentApproximationBlurred.getPixel(bx, by);
      Color current = Color.fromARGB(
        255,
        currentPixel.r.toInt(),
        currentPixel.g.toInt(),
        currentPixel.b.toInt(),
      );

      // Calculate error before
      errorBefore += ColorUtils.calculateAsymmetricError(original, current);

      // Simulate adding thread
      Color afterThread = ColorUtils.blendColors(
        current,
        thread.color,
        thread.opacity,
      );
      errorAfter += ColorUtils.calculateAsymmetricError(original, afterThread);
    }

    return errorBefore - errorAfter;
  }
}