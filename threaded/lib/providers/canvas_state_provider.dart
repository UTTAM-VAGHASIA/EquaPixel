import 'package:flutter/material.dart';

class CanvasStateProvider {
  // ValueNotifiers for granular updates
  final ValueNotifier<double> zoomLevel = ValueNotifier(1.0);
  final ValueNotifier<Offset> panOffset = ValueNotifier(Offset.zero);
  final ValueNotifier<bool> showNailNumbers = ValueNotifier(false);
  final ValueNotifier<bool> showFrame = ValueNotifier(true);
  final ValueNotifier<bool> showOriginalImage = ValueNotifier(false);

  void resetView() {
    zoomLevel.value = 1.0;
    panOffset.value = Offset.zero;
  }

  void setZoom(double zoom) {
    zoomLevel.value = zoom.clamp(0.5, 5.0);
  }

  void setPan(Offset offset) {
    panOffset.value = offset;
  }

  void toggleNailNumbers() {
    showNailNumbers.value = !showNailNumbers.value;
  }

  void toggleFrame() {
    showFrame.value = !showFrame.value;
  }

  void toggleOriginalImage() {
    showOriginalImage.value = !showOriginalImage.value;
  }

  void dispose() {
    zoomLevel.dispose();
    panOffset.dispose();
    showNailNumbers.dispose();
    showFrame.dispose();
    showOriginalImage.dispose();
  }
}