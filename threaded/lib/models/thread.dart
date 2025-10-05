import 'package:flutter/material.dart';

class Thread {
  final Color color;
  final double opacity;
  final String name;

  Thread({
    required this.color,
    this.opacity = 0.2,
    required this.name,
  });

  Thread copyWith({
    Color? color,
    double? opacity,
    String? name,
  }) {
    return Thread(
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Thread(name: $name, opacity: $opacity)';
}