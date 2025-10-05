import 'package:flutter/material.dart';

class Nail {
  final int id;
  final Offset position;

  Nail({
    required this.id,
    required this.position,
  });

  Nail copyWith({
    int? id,
    Offset? position,
  }) {
    return Nail(
      id: id ?? this.id,
      position: position ?? this.position,
    );
  }

  @override
  String toString() => 'Nail(id: $id, position: $position)';
}