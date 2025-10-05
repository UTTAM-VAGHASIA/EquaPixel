import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/connection.dart';
import '../models/frame.dart';
import '../models/string_art_config.dart';
import '../models/thread.dart';
import '../services/error_calculator.dart';
import '../services/image_processor.dart';
import '../services/string_art_generator.dart';

enum GenerationStatus {
  idle,
  preprocessing,
  generating,
  completed,
  error,
  cancelled,
}

class StringArtProvider extends ChangeNotifier {
  // State
  GenerationStatus _status = GenerationStatus.idle;
  img.Image? _originalImage;
  img.Image? _approximationImage;
  List<Connection> _connections = [];
  double _progress = 0.0;
  String? _errorMessage;
  Thread? _currentThread;

  // Configuration
  StringArtConfig? _config;
  Frame? _activeFrame; // frozen frame used during current generation

  // Service instances
  StringArtGenerator? _generator;

  // Getters
  GenerationStatus get status => _status;
  img.Image? get originalImage => _originalImage;
  img.Image? get approximationImage => _approximationImage;
  List<Connection> get connections => List.unmodifiable(_connections);
  double get progress => _progress;
  String? get errorMessage => _errorMessage;
  Thread? get currentThread => _currentThread;
  StringArtConfig? get config => _config;
  int get totalConnections => _connections.length;
  Frame? get activeFrame => _activeFrame;

  // Computed properties
  bool get isGenerating => _status == GenerationStatus.generating;
  bool get canGenerate => _originalImage != null && _config != null;
  bool get hasResult => _status == GenerationStatus.completed && _connections.isNotEmpty;

  // Set configuration
  void setConfig(StringArtConfig config) {
    _config = config;
    notifyListeners();
  }

  // Load image
  Future<void> loadImage(Uint8List imageBytes) async {
    try {
      _status = GenerationStatus.preprocessing;
      _errorMessage = null;
      notifyListeners();

      _originalImage = await ImageProcessor.decodeImage(imageBytes);

      if (_originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image if config is available
      if (_config != null) {
        _originalImage = await ImageProcessor.preprocessImage(
          _originalImage!,
          _config!.frame.size,
        );
      }

      _status = GenerationStatus.idle;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load image: ${e.toString()}';
      _status = GenerationStatus.error;
      notifyListeners();
    }
  }

  // Start generation
  Future<void> startGeneration() async {
    if (!canGenerate) return;

    try {
      if (kDebugMode) {
        print('[Provider] startGeneration: nails=${_config!.frame.nails.length}, frame=${_config!.frame.shape}, size=${_config!.frame.size}, threads=${_config!.threads.length}');
      }
      _status = GenerationStatus.generating;
      _progress = 0.0;
      _connections.clear();
      _errorMessage = null;
      _approximationImage = null;
      _activeFrame = _config!.frame; // freeze frame for rendering consistency
      notifyListeners();

      // Preprocess image to match frame size
      final processedImage = await ImageProcessor.preprocessImage(
        _originalImage!,
        _config!.frame.size,
      );

      // Create error calculator
      img.Image originalBlurred = ImageProcessor.createBlurredVersion(
        processedImage,
        _config!.blurFactor,
      );

      ErrorCalculator errorCalculator = ErrorCalculator(
        originalImage: processedImage,
        originalBlurred: originalBlurred,
        blurFactor: _config!.blurFactor,
      );

      // Create generator
      _generator = StringArtGenerator(
        config: _config!,
        originalImage: processedImage,
        errorCalculator: errorCalculator,
      );

      // Listen to generation progress
      await for (GenerationProgress progress in _generator!.generate()) {
        if (_status == GenerationStatus.cancelled) {
          break;
        }

        _connections = progress.connections;
        _approximationImage = progress.approximationImage;
        _progress = progress.overallProgress;
        _currentThread = progress.currentThread;
        notifyListeners();
      }

      if (_status != GenerationStatus.cancelled) {
        _status = GenerationStatus.completed;
        _progress = 1.0;
        if (kDebugMode) {
          print('[Provider] generation completed: connections=${_connections.length}');
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Generation failed: ${e.toString()}';
      _status = GenerationStatus.error;
      if (kDebugMode) {
        print('[Provider] generation error: $e');
      }
      notifyListeners();
    }
  }

  // Cancel generation
  void cancelGeneration() {
    if (_status == GenerationStatus.generating) {
      _generator?.cancel();
      _status = GenerationStatus.cancelled;
      notifyListeners();
    }
  }

  // Reset
  void reset() {
    _status = GenerationStatus.idle;
    _originalImage = null;
    _approximationImage = null;
    _connections.clear();
    _progress = 0.0;
    _errorMessage = null;
    _currentThread = null;
    _generator = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _generator = null;
    super.dispose();
  }
}