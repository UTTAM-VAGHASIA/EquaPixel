import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/connection.dart';
import '../models/frame.dart';
import '../models/nail.dart';

class StringArtPainter extends CustomPainter {
  final List<Connection> connections;
  final Frame? frame;
  final img.Image? approximationImage;
  final bool showNailNumbers;
  final bool showFrame;

  StringArtPainter({
    required this.connections,
    this.frame,
    this.approximationImage,
    this.showNailNumbers = false,
    this.showFrame = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (frame == null) return;

    // Draw frame background
    if (showFrame) {
      _drawFrame(canvas);
    }

    // Draw connections
    for (Connection connection in connections) {
      _drawConnection(canvas, connection);
    }

    // Draw nails
    if (showFrame) {
      _drawNails(canvas);
    }

    // Draw nail numbers
    if (showNailNumbers) {
      _drawNailNumbers(canvas);
    }
  }

  void _drawFrame(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (frame!.shape) {
      case FrameShape.circle:
        canvas.drawCircle(
          frame!.center,
          frame!.size.width / 2,
          paint,
        );
        break;
      case FrameShape.square:
        final rect = Rect.fromCenter(
          center: frame!.center,
          width: frame!.size.width,
          height: frame!.size.height,
        );
        canvas.drawRect(rect, paint);
        break;
      default:
        break;
    }
  }

  void _drawConnection(Canvas canvas, Connection connection) {
    Nail fromNail = frame!.nails[connection.fromNailId];
    Nail toNail = frame!.nails[connection.toNailId];

    final paint = Paint()
      ..color = connection.thread.color.withValues(alpha: connection.thread.opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(fromNail.position, toNail.position, paint);
  }

  void _drawNails(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (Nail nail in frame!.nails) {
      canvas.drawCircle(nail.position, 2.0, paint);
    }
  }

  void _drawNailNumbers(Canvas canvas) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (Nail nail in frame!.nails) {
      final textSpan = TextSpan(
        text: nail.id.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        nail.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StringArtPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        showNailNumbers != oldDelegate.showNailNumbers ||
        showFrame != oldDelegate.showFrame;
  }
}