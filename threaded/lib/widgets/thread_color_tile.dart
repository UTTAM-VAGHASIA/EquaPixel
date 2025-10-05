import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/thread.dart';
import '../providers/config_provider.dart';

class ThreadColorTile extends StatelessWidget {
  final Thread thread;
  final int index;

  const ThreadColorTile({
    super.key,
    required this.thread,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final configProvider = context.read<ConfigProvider>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: thread.color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(thread.name),
        subtitle: Text('Opacity: ${(thread.opacity * 100).toStringAsFixed(0)}%'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, configProvider),
            ),
            if (configProvider.threads.length > 1)
              IconButton(
                icon: Icon(Icons.delete, size: 20),
                onPressed: () => configProvider.removeThread(index),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ConfigProvider configProvider) {
    Color selectedColor = thread.color;
    double selectedOpacity = thread.opacity;
    String selectedName = thread.name;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Thread'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Thread Name'),
                  controller: TextEditingController(text: selectedName),
                  onChanged: (value) => selectedName = value,
                ),
                SizedBox(height: 16),
                Text('Color'),
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
                configProvider.updateThread(
                  index,
                  Thread(
                    color: selectedColor,
                    opacity: selectedOpacity,
                    name: selectedName.isEmpty ? 'Thread ${index + 1}' : selectedName,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}