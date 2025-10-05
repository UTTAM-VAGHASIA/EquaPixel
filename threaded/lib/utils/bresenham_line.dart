import 'package:flutter/material.dart';

class BresenhamLine {
  /// Get all pixels on a line from start to end using Bresenham's algorithm
  static List<Offset> getPixels(Offset start, Offset end) {
    List<Offset> pixels = [];
    
    int x0 = start.dx.round();
    int y0 = start.dy.round();
    int x1 = end.dx.round();
    int y1 = end.dy.round();
    
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;
    
    int x = x0;
    int y = y0;
    
    while (true) {
      pixels.add(Offset(x.toDouble(), y.toDouble()));
      
      if (x == x1 && y == y1) break;
      
      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }
    
    return pixels;
  }
}