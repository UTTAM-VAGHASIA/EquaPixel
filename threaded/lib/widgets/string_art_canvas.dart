import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canvas_state_provider.dart';
import '../providers/string_art_provider.dart';
import 'custom_painter.dart';

class StringArtCanvas extends StatelessWidget {
  const StringArtCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final stringArtProvider = context.watch<StringArtProvider>();
    final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Main canvas
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: CustomPaint(
                size: Size(
                  stringArtProvider.config?.frame.size.width ?? 500,
                  stringArtProvider.config?.frame.size.height ?? 500,
                ),
                painter: StringArtPainter(
                  connections: stringArtProvider.connections,
                  frame: stringArtProvider.activeFrame ?? stringArtProvider.config?.frame,
                  approximationImage: stringArtProvider.approximationImage,
                ),
              ),
            ),
          ),

          // Placeholder when no image
          if (stringArtProvider.originalImage == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Load an image to get started',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Controls overlay
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: canvasState.showNailNumbers,
                      builder: (context, show, child) {
                        return IconButton(
                          icon: Icon(show ? Icons.numbers : Icons.numbers_outlined),
                          tooltip: 'Toggle Nail Numbers',
                          onPressed: () => canvasState.toggleNailNumbers(),
                        );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: canvasState.showFrame,
                      builder: (context, show, child) {
                        return IconButton(
                          icon: Icon(show ? Icons.border_outer : Icons.border_clear),
                          tooltip: 'Toggle Frame',
                          onPressed: () => canvasState.toggleFrame(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Status indicator
          if (stringArtProvider.isGenerating)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generating String Art...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: stringArtProvider.progress),
                      SizedBox(height: 8),
                      Text(
                        '${(stringArtProvider.progress * 100).toStringAsFixed(1)}% complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}