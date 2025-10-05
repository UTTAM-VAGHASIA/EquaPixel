import 'package:flutter/material.dart';
import '../widgets/control_panel.dart';
import '../widgets/string_art_canvas.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('String Art Editor'),
        backgroundColor: Colors.blue[700],
      ),
      body: Row(
        children: [
          // Left panel - controls
          SizedBox(
            width: 350,
            child: ControlPanel(),
          ),

          // Right panel - canvas
          Expanded(
            child: StringArtCanvas(),
          ),
        ],
      ),
    );
  }
}