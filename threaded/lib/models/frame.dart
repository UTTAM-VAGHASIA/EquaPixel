import 'dart:math';
import 'package:flutter/material.dart';
import 'nail.dart';

enum FrameShape { circle, square, hexagon }

class Frame {
  final FrameShape shape;
  final List<Nail> nails;
  final Size size;
  final Offset center;

  Frame({
    required this.shape,
    required this.nails,
    required this.size,
    required this.center,
  });

  // Circular frame factory
  factory Frame.circular({
    required int nailCount,
    required double radius,
    required Offset center,
  }) {
    List<Nail> nails = [];
    for (int i = 0; i < nailCount; i++) {
      double angle = 2 * pi * i / nailCount;
      Offset position = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      nails.add(Nail(id: i, position: position));
    }
    
    return Frame(
      shape: FrameShape.circle,
      nails: nails,
      size: Size(radius * 2, radius * 2),
      center: center,
    );
  }

  // Square frame factory
  factory Frame.square({
    required int nailCount,
    required double sideLength,
    required Offset center,
  }) {
    List<Nail> nails = [];
    int nailsPerSide = (nailCount / 4).floor();
    int currentId = 0;
    
    double halfSize = sideLength / 2;
    double topLeftX = center.dx - halfSize;
    double topLeftY = center.dy - halfSize;
    
    // Top side
    for (int i = 0; i < nailsPerSide; i++) {
      double x = topLeftX + (sideLength * i / nailsPerSide);
      nails.add(Nail(id: currentId++, position: Offset(x, topLeftY)));
    }
    
    // Right side
    for (int i = 0; i < nailsPerSide; i++) {
      double y = topLeftY + (sideLength * i / nailsPerSide);
      nails.add(Nail(id: currentId++, position: Offset(topLeftX + sideLength, y)));
    }
    
    // Bottom side
    for (int i = 0; i < nailsPerSide; i++) {
      double x = topLeftX + sideLength - (sideLength * i / nailsPerSide);
      nails.add(Nail(id: currentId++, position: Offset(x, topLeftY + sideLength)));
    }
    
    // Left side
    for (int i = 0; i < nailsPerSide; i++) {
      double y = topLeftY + sideLength - (sideLength * i / nailsPerSide);
      nails.add(Nail(id: currentId++, position: Offset(topLeftX, y)));
    }
    
    return Frame(
      shape: FrameShape.square,
      nails: nails,
      size: Size(sideLength, sideLength),
      center: center,
    );
  }
}