import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Decode image from bytes
  static Future<img.Image?> decodeImage(Uint8List bytes) async {
    return await Future(() => img.decodeImage(bytes));
  }

  /// Resize image to target size
  static Future<img.Image> preprocessImage(
    img.Image source,
    Size targetSize,
  ) async {
    return await Future(() {
      return img.copyResize(
        source,
        width: targetSize.width.toInt(),
        height: targetSize.height.toInt(),
        interpolation: img.Interpolation.linear,
      );
    });
  }

  /// Create downscaled version for blur simulation
  static img.Image createBlurredVersion(
    img.Image source,
    double blurFactor,
  ) {
    int newWidth = (source.width / blurFactor).round().clamp(1, source.width);
    int newHeight = (source.height / blurFactor).round().clamp(1, source.height);
    
    return img.copyResize(
      source,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.average,
    );
  }

  /// Create blank white image
  static img.Image createBlankImage(int width, int height) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    return image;
  }

  /// Convert img.Image to Flutter Image widget
  static Future<Image> toFlutterImage(img.Image image) async {
    final bytes = img.encodePng(image);
    return Image.memory(Uint8List.fromList(bytes));
  }
}