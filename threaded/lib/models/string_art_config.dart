import 'frame.dart';
import 'thread.dart';

class StringArtConfig {
  final Frame frame;
  final List<Thread> threads;
  final int maxIterationsPerColor;
  final double blurFactor;
  final int skipLastNails;
  final double minErrorReduction;

  StringArtConfig({
    required this.frame,
    required this.threads,
    this.maxIterationsPerColor = 3000,
    this.blurFactor = 3.0,
    this.skipLastNails = 20,
    this.minErrorReduction = 0.0,
  });

  StringArtConfig copyWith({
    Frame? frame,
    List<Thread>? threads,
    int? maxIterationsPerColor,
    double? blurFactor,
    int? skipLastNails,
    double? minErrorReduction,
  }) {
    return StringArtConfig(
      frame: frame ?? this.frame,
      threads: threads ?? this.threads,
      maxIterationsPerColor: maxIterationsPerColor ?? this.maxIterationsPerColor,
      blurFactor: blurFactor ?? this.blurFactor,
      skipLastNails: skipLastNails ?? this.skipLastNails,
      minErrorReduction: minErrorReduction ?? this.minErrorReduction,
    );
  }
}