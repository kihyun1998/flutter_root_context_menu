import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Context Menu Playground',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PlaygroundPage(),
    );
  }
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // Animation settings
  ContextMenuAnimationBuilder _selectedAnimation =
      ContextMenuAnimations.popup;
  String _animationName = 'Popup';
  double _animationDuration = 200;

  // Style settings
  Color _backgroundColor = Colors.white;
  Color _hoverColor = const Color(0xFFE0E0E0);
  Color _textColor = Colors.black;
  double _elevation = 8.0;
  double _itemHeight = 40.0;

  // Last action
  String _lastAction = 'Right-click in the playground area';

  final Map<String, ContextMenuAnimationBuilder> _animations = {
    'Popup': ContextMenuAnimations.popup,
    'Fade': ContextMenuAnimations.fade,
    'Slide Up': ContextMenuAnimations.slideUp,
    'Slide Down': ContextMenuAnimations.slideDown,
    'Slide Right': ContextMenuAnimations.slideRight,
    'Bounce': ContextMenuAnimations.bounce,
    'Scale': ContextMenuAnimations.scale,
    'None': ContextMenuAnimations.none,
  };

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
            // Desktop layout: side by side
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _buildControlPanel(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPlayground()),
              ],
            );
          } else {
            // Mobile layout: stacked
            return Column(
              children: [
                Expanded(flex: 2, child: _buildPlayground()),
                const Divider(height: 1),
                Expanded(flex: 3, child: _buildControlPanel()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Control Panel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Animation Type
          const Text('Animation Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _animationName,
            isExpanded: true,
            items: _animations.keys.map((name) {
              return DropdownMenuItem(value: name, child: Text(name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _animationName = value!;
                _selectedAnimation = _animations[value]!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Animation Duration
          const Text('Animation Duration', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _animationDuration,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  label: '${_animationDuration.toInt()}ms',
                  onChanged: (value) {
                    setState(() {
                      _animationDuration = value;
                    });
                  },
                ),
              ),
              Text('${_animationDuration.toInt()}ms'),
            ],
          ),
          const SizedBox(height: 20),

          // Background Color
          const Text('Background Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _colorButton(Colors.white, 'White'),
              _colorButton(const Color(0xFF2C2C2C), 'Dark'),
              _colorButton(Colors.blue.shade50, 'Blue'),
              _colorButton(Colors.green.shade50, 'Green'),
              _colorButton(Colors.purple.shade50, 'Purple'),
            ],
          ),
          const SizedBox(height: 20),

          // Text Color
          const Text('Text Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _colorButton(Colors.black, 'Black', isTextColor: true),
              _colorButton(Colors.white, 'White', isTextColor: true),
              _colorButton(Colors.blue.shade900, 'Blue', isTextColor: true),
              _colorButton(Colors.green.shade900, 'Green', isTextColor: true),
              _colorButton(Colors.red, 'Red', isTextColor: true),
            ],
          ),
          const SizedBox(height: 20),

          // Elevation
          const Text('Elevation', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _elevation,
                  min: 0,
                  max: 24,
                  divisions: 12,
                  label: _elevation.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _elevation = value;
                    });
                  },
                ),
              ),
              Text(_elevation.toInt().toString()),
            ],
          ),
          const SizedBox(height: 20),

          // Item Height
          const Text('Item Height', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _itemHeight,
                  min: 30,
                  max: 60,
                  divisions: 6,
                  label: _itemHeight.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _itemHeight = value;
                    });
                  },
                ),
              ),
              Text(_itemHeight.toInt().toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorButton(Color color, String label, {bool isTextColor = false}) {
    final isSelected = isTextColor ? _textColor == color : _backgroundColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isTextColor) {
            _textColor = color;
            // Auto-adjust hover color
            if (color == Colors.white) {
              _hoverColor = Colors.grey.shade700;
            } else {
              _hoverColor = _backgroundColor == Colors.white
                  ? const Color(0xFFE0E0E0)
                  : Colors.white.withOpacity(0.1);
            }
          } else {
            _backgroundColor = color;
            // Auto-adjust hover color
            if (color == Colors.white) {
              _hoverColor = const Color(0xFFE0E0E0);
            } else {
              _hoverColor = Colors.white.withOpacity(0.1);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayground() {
    return Container(
      color: Colors.grey.shade100,
      child: ContextMenuArea(
        child: GestureDetector(
          onSecondaryTapDown: (details) {
            showContextMenu(
              context: context,
              position: details.globalPosition,
              items: [
                ContextMenuItem(
                  label: 'Copy',
                  icon: const Icon(Icons.copy, size: 18),
                  onTap: () {
                    setState(() {
                      _lastAction = 'Copy clicked';
                    });
                  },
                ),
                ContextMenuItem(
                  label: 'Paste',
                  icon: const Icon(Icons.paste, size: 18),
                  onTap: () {
                    setState(() {
                      _lastAction = 'Paste clicked';
                    });
                  },
                ),
                ContextMenuItem(
                  label: 'Cut',
                  icon: const Icon(Icons.cut, size: 18),
                  onTap: () {
                    setState(() {
                      _lastAction = 'Cut clicked';
                    });
                  },
                ),
                ContextMenuItem.divider(),
                ContextMenuItem(
                  label: 'Select All',
                  icon: const Icon(Icons.select_all, size: 18),
                  onTap: () {
                    setState(() {
                      _lastAction = 'Select All clicked';
                    });
                  },
                ),
                ContextMenuItem(
                  label: 'Refresh',
                  icon: const Icon(Icons.refresh, size: 18),
                  onTap: () {
                    setState(() {
                      _lastAction = 'Refresh clicked';
                    });
                  },
                ),
                ContextMenuItem.divider(),
                ContextMenuItem(
                  label: 'Delete',
                  icon: const Icon(Icons.delete, size: 18),
                  textColor: Colors.red,
                  onTap: () {
                    setState(() {
                      _lastAction = 'Delete clicked';
                    });
                  },
                ),
              ],
              config: ContextMenuConfig(
                backgroundColor: _backgroundColor,
                hoverColor: _hoverColor,
                textStyle: TextStyle(color: _textColor, fontSize: 14),
                elevation: _elevation,
                itemHeight: _itemHeight,
                animationBuilder: _selectedAnimation,
                animationDuration: Duration(milliseconds: _animationDuration.toInt()),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mouse,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Playground Area',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Right-click anywhere here to test',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Last Action:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastAction,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
