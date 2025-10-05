import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/connection.dart';
import '../models/nail.dart';
import '../models/string_art_config.dart';
import '../models/thread.dart';
import '../utils/bresenham_line.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import 'error_calculator.dart';
import 'image_processor.dart';

class GenerationProgress {
  final List<Connection> connections;
  final Thread currentThread;
  final img.Image approximationImage;
  final double progress;
  final int threadIndex;
  final int totalThreads;

  GenerationProgress({
    required this.connections,
    required this.currentThread,
    required this.approximationImage,
    required this.progress,
    required this.threadIndex,
    required this.totalThreads,
  });

  double get overallProgress {
    return (threadIndex + progress) / totalThreads;
  }
}

class StringArtGenerator {
  final StringArtConfig config;
  final img.Image originalImage;
  final ErrorCalculator errorCalculator;

  late img.Image approximationImage;
  late img.Image approximationBlurred;

  final List<Connection> _connections = [];
  final Set<int> _recentNails = {};
  bool _isCancelled = false;
  int _iterationsSinceRestart = 0;
  int _plateauSteps = 0;

  StringArtGenerator({
    required this.config,
    required this.originalImage,
    required this.errorCalculator,
  }) {
    _initializeApproximation();
  }

  void _initializeApproximation() {
    // Start with white canvas
    approximationImage = ImageProcessor.createBlankImage(
      originalImage.width,
      originalImage.height,
    );

    // Create blurred version
    approximationBlurred = ImageProcessor.createBlurredVersion(
      approximationImage,
      config.blurFactor,
    );
  }

  Stream<GenerationProgress> generate() async* {
    _isCancelled = false;
    _connections.clear();

    for (int threadIdx = 0; threadIdx < config.threads.length; threadIdx++) {
      if (_isCancelled) break;

      Thread thread = config.threads[threadIdx];
      yield* _generateForThread(thread, threadIdx);
    }
  }

  Stream<GenerationProgress> _generateForThread(
    Thread thread,
    int threadIndex,
  ) async* {
    if (kDebugMode) {
      debugPrint('[Generator] Start thread ${thread.name} (#${threadIndex + 1}/${config.threads.length})');
      debugPrint('[Generator] params: iterations=${config.maxIterationsPerColor}, blur=${config.blurFactor}, skipLast=${config.skipLastNails}, minErr=${config.minErrorReduction.toStringAsFixed(6)}');
    }
    int currentNailId = 0;
    _recentNails.clear();

    int totalIterations = config.maxIterationsPerColor;

    double dynamicThreshold = AppConstants.initialMinReduction;
    for (int iteration = 0; iteration < totalIterations; iteration++) {
      if (_isCancelled) break;

      int? bestNailId;
      double bestErrorReduction = -double.infinity;
      int candidateEvaluations = 0;

      // Try all possible next nails
      for (Nail candidate in config.frame.nails) {
        if (candidate.id == currentNailId) continue;
        if (_recentNails.contains(candidate.id)) continue;
        candidateEvaluations++;

        Nail currentNail = config.frame.nails[currentNailId];
        List<Offset> linePixels = BresenhamLine.getPixels(
          currentNail.position,
          candidate.position,
        );

        double errorReduction = errorCalculator.calculateErrorReduction(
          linePixels: linePixels,
          currentApproximation: approximationImage,
          currentApproximationBlurred: approximationBlurred,
          thread: thread,
        );

        if (errorReduction > bestErrorReduction) {
          bestErrorReduction = errorReduction;
          bestNailId = candidate.id;
        }
      }

      // Adaptive acceptance: accept small or negative moves within allowance
      if (bestNailId == null) {
        if (kDebugMode) {
          debugPrint('[Generator] no candidate at iter=$iteration, attempting plateau allowance');
        }
        if (_plateauSteps >= AppConstants.plateauAllowance) {
          if (kDebugMode) {
            debugPrint('[Generator] early stop at iter=$iteration (plateau exceeded), nail=$currentNailId, candidates=$candidateEvaluations');
          }
          break;
        } else {
          _plateauSteps++;
          continue;
        }
      }

      // Commit the connection
      Connection connection = Connection(
        fromNailId: currentNailId,
        toNailId: bestNailId,
        thread: thread,
        errorReduction: bestErrorReduction,
      );

      _connections.add(connection);
      _drawConnection(connection);

      // Update recent nails
      _recentNails.add(bestNailId);
      if (_recentNails.length > config.skipLastNails) {
        _recentNails.remove(_recentNails.first);
      }

      currentNailId = bestNailId;
      _iterationsSinceRestart++;

      // Periodic restart heuristic: jump to a distant nail every N steps
      if (_iterationsSinceRestart % AppConstants.restartInterval == 0) {
        // Choose the nail farthest from current to escape local minima
        final Nail curr = config.frame.nails[currentNailId];
        double maxDist = -1.0;
        int farthestId = currentNailId;
        for (final Nail n in config.frame.nails) {
          final dx = n.position.dx - curr.position.dx;
          final dy = n.position.dy - curr.position.dy;
          final d2 = dx * dx + dy * dy;
          if (d2 > maxDist) {
            maxDist = d2;
            farthestId = n.id;
          }
        }
        if (kDebugMode) {
          debugPrint('[Generator] restart: iter=$_iterationsSinceRestart, from=$currentNailId -> $farthestId');
        }
        currentNailId = farthestId;
        _recentNails.clear();
      }

      // Threshold decay
      if (iteration > 0 && iteration % AppConstants.reductionDecayInterval == 0) {
        dynamicThreshold = (dynamicThreshold * AppConstants.reductionDecayFactor)
            .clamp(AppConstants.minReductionFloor, dynamicThreshold);
        if (kDebugMode) {
          debugPrint('[Generator] threshold decayed to ${dynamicThreshold.toStringAsExponential(3)}');
        }
      }

      // Track plateau: reset when improvement exceeds tolerance
      if (bestErrorReduction > AppConstants.improvementTolerance) {
        _plateauSteps = 0;
      } else {
        _plateauSteps++;
      }

      // Yield progress periodically
      if (iteration % AppConstants.progressUpdateInterval == 0 ||
          iteration == totalIterations - 1) {
        if (kDebugMode) {
          debugPrint('[Generator] iter=$iteration/$totalIterations, thread=${thread.name}, conn=${_connections.length}, lastBest=${bestErrorReduction.toStringAsExponential(3)}');
        }
        yield GenerationProgress(
          connections: List.from(_connections),
          currentThread: thread,
          approximationImage: approximationImage,
          progress: iteration / totalIterations,
          threadIndex: threadIndex,
          totalThreads: config.threads.length,
        );

        // Allow UI to update
        await Future.delayed(Duration.zero);
      }
    }
  }

  void _drawConnection(Connection connection) {
    Nail fromNail = config.frame.nails[connection.fromNailId];
    Nail toNail = config.frame.nails[connection.toNailId];

    List<Offset> pixels = BresenhamLine.getPixels(
      fromNail.position,
      toNail.position,
    );

    for (Offset pixel in pixels) {
      int x = pixel.dx.round();
      int y = pixel.dy.round();

      if (x < 0 || x >= approximationImage.width ||
          y < 0 || y >= approximationImage.height) {
        continue;
      }

      // Get current pixel
      final currentPixel = approximationImage.getPixel(x, y);
      Color current = Color.fromARGB(
        255,
        currentPixel.r.toInt(),
        currentPixel.g.toInt(),
        currentPixel.b.toInt(),
      );

      // Blend with thread
      Color blended = ColorUtils.blendColors(
        current,
        connection.thread.color,
        connection.thread.opacity,
      );

      // Set pixel
      approximationImage.setPixel(
        x,
        y,
        img.ColorRgb8(blended.r.toInt(), blended.g.toInt(), blended.b.toInt()),
      );
    }

    // Update blurred version periodically
    if (_connections.length % AppConstants.blurUpdateInterval == 0) {
      approximationBlurred = ImageProcessor.createBlurredVersion(
        approximationImage,
        config.blurFactor,
      );
    }
  }

  void cancel() {
    _isCancelled = true;
  }

  List<Connection> get connections => List.unmodifiable(_connections);
}