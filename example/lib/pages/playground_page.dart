import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

import '../models/playground_settings.dart';
import '../widgets/control_panel.dart';
import '../widgets/playground_content.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final PlaygroundSettings _settings = PlaygroundSettings();
  String _lastAction = 'Right-click in the playground area';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Context Menu Playground'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: ControlPanel(
                    settings: _settings,
                    onChanged: () => setState(() {}),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPlayground()),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(flex: 2, child: _buildPlayground()),
                const Divider(height: 1),
                Expanded(
                  flex: 3,
                  child: ControlPanel(
                    settings: _settings,
                    onChanged: () => setState(() {}),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildPlayground() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(40),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: ContextMenuArea(
          child: PlaygroundContent(
            lastAction: _lastAction,
            onActionChanged: (action) => setState(() => _lastAction = action),
            config: _settings.toConfig(),
          ),
        ),
      ),
    );
  }
}
