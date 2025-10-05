class AppConstants {
  // Frame constraints
  static const double minFrameSize = 200.0;
  static const double maxFrameSize = 1000.0;
  static const double defaultFrameSize = 500.0;
  
  // Nail constraints
  static const int minNailCount = 50;
  static const int maxNailCount = 500;
  static const int defaultNailCount = 200;
  
  // Algorithm constraints
  static const int minIterations = 500;
  static const int maxIterations = 10000;
  static const int defaultIterations = 3000;
  
  static const double minBlurFactor = 1.0;
  static const double maxBlurFactor = 10.0;
  static const double defaultBlurFactor = 3.0;
  static const double defaultMinErrorReduction = -1e-6;
  
  static const int minSkipNails = 5;
  static const int maxSkipNails = 50;
  static const int defaultSkipNails = 20;
  
  // Thread constraints
  static const double minOpacity = 0.05;
  static const double maxOpacity = 0.5;
  static const double defaultOpacity = 0.2;
  
  // UI
  static const int progressUpdateInterval = 10;
  static const int blurUpdateInterval = 25;

  // Search heuristics
  static const int restartInterval = 100; // iterations between restarts

  // Adaptive threshold / plateau control
  static const double initialMinReduction = 1e-5;
  static const double minReductionFloor = -1e-6;
  static const int reductionDecayInterval = 100;
  static const double reductionDecayFactor = 0.5; // halve threshold periodically
  static const int plateauAllowance = 200; // allow this many non-improving steps
  static const double improvementTolerance = 1e-9;
}