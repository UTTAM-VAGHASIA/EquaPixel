import 'package:flutter/material.dart';
import '../models/frame.dart';
import '../models/string_art_config.dart';
import '../models/thread.dart';
import '../utils/constants.dart';

class ConfigProvider extends ChangeNotifier {
  // Frame settings
  FrameShape _frameShape = FrameShape.circle;
  int _nailCount = AppConstants.defaultNailCount;
  double _frameSize = AppConstants.defaultFrameSize;

  // Thread settings
  List<Thread> _threads = [
    Thread(
      color: Colors.black,
      opacity: AppConstants.defaultOpacity,
      name: 'Black',
    ),
  ];

  // Algorithm settings
  int _maxIterationsPerColor = AppConstants.defaultIterations;
  double _blurFactor = AppConstants.defaultBlurFactor;
  int _skipLastNails = AppConstants.defaultSkipNails;
  final double _minErrorReduction = 0.0;

  // Getters
  FrameShape get frameShape => _frameShape;
  int get nailCount => _nailCount;
  double get frameSize => _frameSize;
  List<Thread> get threads => List.unmodifiable(_threads);
  int get maxIterationsPerColor => _maxIterationsPerColor;
  double get blurFactor => _blurFactor;
  int get skipLastNails => _skipLastNails;
  double get minErrorReduction => _minErrorReduction;

  // Setters
  void setFrameShape(FrameShape shape) {
    _frameShape = shape;
    notifyListeners();
  }

  void setNailCount(int count) {
    _nailCount = count.clamp(
      AppConstants.minNailCount,
      AppConstants.maxNailCount,
    );
    notifyListeners();
  }

  void setFrameSize(double size) {
    _frameSize = size.clamp(
      AppConstants.minFrameSize,
      AppConstants.maxFrameSize,
    );
    notifyListeners();
  }

  void setMaxIterations(int iterations) {
    _maxIterationsPerColor = iterations.clamp(
      AppConstants.minIterations,
      AppConstants.maxIterations,
    );
    notifyListeners();
  }

  void setBlurFactor(double factor) {
    _blurFactor = factor.clamp(
      AppConstants.minBlurFactor,
      AppConstants.maxBlurFactor,
    );
    notifyListeners();
  }

  void setSkipLastNails(int skip) {
    _skipLastNails = skip.clamp(
      AppConstants.minSkipNails,
      AppConstants.maxSkipNails,
    );
    notifyListeners();
  }

  // Thread management
  void addThread(Thread thread) {
    _threads.add(thread);
    notifyListeners();
  }

  void removeThread(int index) {
    if (_threads.length > 1) {
      _threads.removeAt(index);
      notifyListeners();
    }
  }

  void updateThread(int index, Thread thread) {
    if (index >= 0 && index < _threads.length) {
      _threads[index] = thread;
      notifyListeners();
    }
  }

  // Build config
  StringArtConfig buildConfig() {
    Frame frame;
    Offset center = Offset(_frameSize / 2, _frameSize / 2);

    switch (_frameShape) {
      case FrameShape.circle:
        frame = Frame.circular(
          nailCount: _nailCount,
          radius: _frameSize / 2,
          center: center,
        );
        break;
      case FrameShape.square:
        frame = Frame.square(
          nailCount: _nailCount,
          sideLength: _frameSize,
          center: center,
        );
        break;
      default:
        frame = Frame.circular(
          nailCount: _nailCount,
          radius: _frameSize / 2,
          center: center,
        );
    }

    return StringArtConfig(
      frame: frame,
      threads: List.from(_threads),
      maxIterationsPerColor: _maxIterationsPerColor,
      blurFactor: _blurFactor,
      skipLastNails: _skipLastNails,
      minErrorReduction: _minErrorReduction,
    );
  }

  // Presets
  void loadPreset(String presetName) {
    switch (presetName) {
      case 'portrait':
        _nailCount = 250;
        _maxIterationsPerColor = 3500;
        _blurFactor = 3.0;
        _threads = [
          Thread(color: Colors.black, opacity: 0.15, name: 'Black'),
        ];
        break;
      case 'colorful':
        _nailCount = 200;
        _maxIterationsPerColor = 2000;
        _blurFactor = 3.5;
        _threads = [
          Thread(color: Colors.black, opacity: 0.2, name: 'Black'),
          Thread(color: Colors.red, opacity: 0.15, name: 'Red'),
          Thread(color: Colors.blue, opacity: 0.15, name: 'Blue'),
        ];
        break;
      case 'detailed':
        _nailCount = 300;
        _maxIterationsPerColor = 5000;
        _blurFactor = 2.5;
        _threads = [
          Thread(color: Colors.black, opacity: 0.12, name: 'Black'),
        ];
        break;
    }
    notifyListeners();
  }
}