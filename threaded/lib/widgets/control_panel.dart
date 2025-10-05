import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/frame.dart';
import '../models/thread.dart';
import '../providers/config_provider.dart';
import '../providers/string_art_provider.dart';
import 'thread_color_tile.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final stringArtProvider = context.watch<StringArtProvider>();

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'String Art Generator',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // Image picker
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: stringArtProvider.isGenerating
                    ? null
                    : () => _pickImage(context),
                icon: Icon(Icons.image),
                label: Text('Load Image'),
              ),
            ),

            if (stringArtProvider.originalImage != null) ...[
              SizedBox(height: 8),
              Text(
                'Image loaded: ${stringArtProvider.originalImage!.width}x${stringArtProvider.originalImage!.height}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

            // Presets
            Text('Presets', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('Portrait'),
                  selected: false,
                  onSelected: (_) {
                    configProvider.loadPreset('portrait');
                    _updateConfig(context);
                  },
                ),
                ChoiceChip(
                  label: Text('Colorful'),
                  selected: false,
                  onSelected: (_) {
                    configProvider.loadPreset('colorful');
                    _updateConfig(context);
                  },
                ),
                ChoiceChip(
                  label: Text('Detailed'),
                  selected: false,
                  onSelected: (_) {
                    configProvider.loadPreset('detailed');
                    _updateConfig(context);
                  },
                ),
              ],
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

            // Frame settings
            Text(
              'Frame Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),

            Text('Shape'),
            DropdownButton<FrameShape>(
              value: configProvider.frameShape,
              isExpanded: true,
              items: FrameShape.values.map((shape) {
                return DropdownMenuItem(
                  value: shape,
                  child: Text(shape.name.toUpperCase()),
                );
              }).toList(),
              onChanged: stringArtProvider.isGenerating
                  ? null
                  : (shape) {
                      if (shape != null) {
                        configProvider.setFrameShape(shape);
                        _updateConfig(context);
                      }
                    },
            ),

            SizedBox(height: 16),

            Text('Nail Count: ${configProvider.nailCount}'),
            Slider(
              value: configProvider.nailCount.toDouble(),
              min: 50,
              max: 500,
              divisions: 45,
              label: configProvider.nailCount.toString(),
              onChanged: stringArtProvider.isGenerating
                  ? null
                  : (value) {
                      configProvider.setNailCount(value.toInt());
                    },
              onChangeEnd: (value) => _updateConfig(context),
            ),

            SizedBox(height: 16),

            Text(
              'Frame Size: ${configProvider.frameSize.toStringAsFixed(0)}px',
            ),
            Slider(
              value: configProvider.frameSize,
              min: 200,
              max: 1000,
              divisions: 80,
              label: configProvider.frameSize.toStringAsFixed(0),
              onChanged: stringArtProvider.isGenerating
                  ? null
                  : (value) {
                      configProvider.setFrameSize(value);
                    },
              onChangeEnd: (value) => _updateConfig(context),
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

            // Algorithm settings
            Text(
              'Algorithm Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),

            Text(
              'Iterations per Color: ${configProvider.maxIterationsPerColor}',
            ),
            Slider(
              value: configProvider.maxIterationsPerColor.toDouble(),
              min: 500,
              max: 10000,
              divisions: 95,
              label: configProvider.maxIterationsPerColor.toString(),
              onChanged: stringArtProvider.isGenerating
                  ? null
                  : (value) {
                      configProvider.setMaxIterations(value.toInt());
                    },
            ),

            SizedBox(height: 16),

            Text(
              'Blur Factor: ${configProvider.blurFactor.toStringAsFixed(1)}',
            ),
            Slider(
              value: configProvider.blurFactor,
              min: 1.0,
              max: 10.0,
              divisions: 90,
              label: configProvider.blurFactor.toStringAsFixed(1),
              onChanged: stringArtProvider.isGenerating
                  ? null
                  : (value) {
                      configProvider.setBlurFactor(value);
                    },
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

            // Thread colors
            Text(
              'Thread Colors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),

            ...configProvider.threads.asMap().entries.map((entry) {
              return ThreadColorTile(thread: entry.value, index: entry.key);
            }),

            SizedBox(height: 8),

            TextButton.icon(
              onPressed: stringArtProvider.isGenerating
                  ? null
                  : () => _showAddThreadDialog(context),
              icon: Icon(Icons.add),
              label: Text('Add Thread Color'),
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    stringArtProvider.canGenerate &&
                        !stringArtProvider.isGenerating
                    ? () => stringArtProvider.startGeneration()
                    : null,
                child: stringArtProvider.isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating...'),
                        ],
                      )
                    : Text(
                        'Generate String Art',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            // Progress indicator
            if (stringArtProvider.isGenerating) ...[
              SizedBox(height: 16),
              LinearProgressIndicator(value: stringArtProvider.progress),
              SizedBox(height: 8),
              Text(
                'Progress: ${(stringArtProvider.progress * 100).toStringAsFixed(1)}%\n'
                'Thread: ${stringArtProvider.currentThread?.name ?? ""}\n'
                'Connections: ${stringArtProvider.totalConnections}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => stringArtProvider.cancelGeneration(),
                child: Text('Cancel Generation'),
              ),
            ],

            // Error message
            if (stringArtProvider.errorMessage != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stringArtProvider.errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
            ],

            // Export button
            if (stringArtProvider.hasResult) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showExportDialog(context),
                  icon: Icon(Icons.download),
                  label: Text('Export Results'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      if (context.mounted) {
        final provider = context.read<StringArtProvider>();
        final configProvider = context.read<ConfigProvider>();
        await provider.loadImage(result.files.first.bytes!);
        provider.setConfig(configProvider.buildConfig());
      }
    }
  }

  void _updateConfig(BuildContext context) {
    final stringArtProvider = context.read<StringArtProvider>();
    final configProvider = context.read<ConfigProvider>();
    stringArtProvider.setConfig(configProvider.buildConfig());
  }

  void _showAddThreadDialog(BuildContext context) {
    Color selectedColor = Colors.black;
    double selectedOpacity = 0.2;
    String selectedName = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Thread Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Thread Name',
                    hintText: 'e.g., Red, Blue',
                  ),
                  onChanged: (value) => selectedName = value,
                ),
                SizedBox(height: 16),
                Text('Select Color'),
                SizedBox(height: 8),
                ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    setState(() => selectedColor = color);
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: true,
                ),
                SizedBox(height: 16),
                Text('Opacity: ${(selectedOpacity * 100).toStringAsFixed(0)}%'),
                Slider(
                  value: selectedOpacity,
                  min: 0.05,
                  max: 0.5,
                  divisions: 45,
                  label: (selectedOpacity * 100).toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() => selectedOpacity = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final configProvider = context.read<ConfigProvider>();
                configProvider.addThread(
                  Thread(
                    color: selectedColor,
                    opacity: selectedOpacity,
                    name: selectedName.isEmpty
                        ? 'Thread ${configProvider.threads.length + 1}'
                        : selectedName,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export as CSV'),
              subtitle: Text('Nail sequence for manual creation'),
              onTap: () {
                // TODO: Implement CSV export
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV export not yet implemented')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Save as PNG'),
              subtitle: Text('Save the generated image'),
              onTap: () {
                // TODO: Implement PNG export
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PNG export not yet implemented')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
