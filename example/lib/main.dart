import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

import 'playground_content.dart';

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
      navigatorObservers: [ContextMenuRouteObserver()],
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
  ContextMenuAnimationBuilder _selectedAnimation = ContextMenuAnimations.popup;
  String _animationName = 'Popup';
  double _animationDuration = 200;

  // Style settings
  Color _backgroundColor = Colors.white;
  Color _hoverColor = const Color(0xFFE0E0E0);
  Color _textColor = Colors.black;
  double _elevation = 8.0;
  double _itemHeight = 40.0;
  double _minWidth = 180.0;
  double _maxWidth = 280.0;

  // Screen padding settings
  double _paddingTop = 0;
  double _paddingBottom = 10;
  double _paddingLeft = 0;
  double _paddingRight = 0;

  // Item styling settings
  double _itemBorderRadius = 0;
  double _itemMarginHorizontal = 0;
  double _itemMarginVertical = 0;

  // Divider and menu styling settings
  double _dividerMarginVertical = 0;
  double _menuPaddingHorizontal = 0;
  double _menuPaddingVertical = 0;

  // BoxShadow settings
  bool _useCustomBoxShadow = false;
  double _shadowBlurRadius = 10.0;
  double _shadowOffsetX = 0.0;
  double _shadowOffsetY = 4.0;
  double _shadowSpreadRadius = 0.0;
  double _shadowOpacity = 0.2;
  Color _shadowColor = Colors.black;

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
                SizedBox(width: 300, child: _buildControlPanel()),
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
          const Text(
            'Animation Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Animation Duration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Background Color',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Text Color',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Elevation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Item Height',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          const SizedBox(height: 20),

          // Min Width
          const Text(
            'Min Width',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _minWidth,
                  min: 100,
                  max: 400,
                  divisions: 30,
                  label: _minWidth.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _minWidth = value;
                      if (_minWidth > _maxWidth) {
                        _maxWidth = _minWidth;
                      }
                    });
                  },
                ),
              ),
              Text(_minWidth.toInt().toString()),
            ],
          ),
          const SizedBox(height: 20),

          // Max Width
          const Text(
            'Max Width',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _maxWidth,
                  min: 100,
                  max: 400,
                  divisions: 30,
                  label: _maxWidth.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _maxWidth = value;
                      if (_maxWidth < _minWidth) {
                        _minWidth = _maxWidth;
                      }
                    });
                  },
                ),
              ),
              Text(_maxWidth.toInt().toString()),
            ],
          ),
          const SizedBox(height: 20),

          // Screen Padding Section
          const Text(
            'Screen Padding',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Padding Top
          const Text('Top', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _paddingTop,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _paddingTop.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _paddingTop = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 40, child: Text('${_paddingTop.toInt()}px')),
            ],
          ),
          const SizedBox(height: 12),

          // Padding Bottom
          const Text('Bottom', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _paddingBottom,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _paddingBottom.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _paddingBottom = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 40, child: Text('${_paddingBottom.toInt()}px')),
            ],
          ),
          const SizedBox(height: 12),

          // Padding Left
          const Text('Left', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _paddingLeft,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _paddingLeft.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _paddingLeft = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 40, child: Text('${_paddingLeft.toInt()}px')),
            ],
          ),
          const SizedBox(height: 12),

          // Padding Right
          const Text('Right', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _paddingRight,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _paddingRight.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _paddingRight = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 40, child: Text('${_paddingRight.toInt()}px')),
            ],
          ),
          const SizedBox(height: 20),

          // Item Styling Section
          const Text(
            'Item Styling',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Item Border Radius
          const Text(
            'Border Radius',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _itemBorderRadius,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _itemBorderRadius.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _itemBorderRadius = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_itemBorderRadius.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item Margin Horizontal
          const Text(
            'Margin Horizontal',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _itemMarginHorizontal,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _itemMarginHorizontal.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _itemMarginHorizontal = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_itemMarginHorizontal.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item Margin Vertical
          const Text(
            'Margin Vertical',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _itemMarginVertical,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: _itemMarginVertical.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _itemMarginVertical = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_itemMarginVertical.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider & Menu Section
          const Text(
            'Divider & Menu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Divider Margin Vertical
          const Text(
            'Divider Margin Vertical',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _dividerMarginVertical,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _dividerMarginVertical.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _dividerMarginVertical = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_dividerMarginVertical.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Menu Padding Horizontal
          const Text(
            'Menu Padding Horizontal',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _menuPaddingHorizontal,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _menuPaddingHorizontal.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _menuPaddingHorizontal = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_menuPaddingHorizontal.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Menu Padding Vertical
          const Text(
            'Menu Padding Vertical',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _menuPaddingVertical,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _menuPaddingVertical.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _menuPaddingVertical = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_menuPaddingVertical.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BoxShadow Section
          const Text(
            'Box Shadow',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Use Custom BoxShadow Toggle
          Row(
            children: [
              const Text(
                'Use Custom Shadow',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Switch(
                value: _useCustomBoxShadow,
                onChanged: (value) {
                  setState(() {
                    _useCustomBoxShadow = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_useCustomBoxShadow) ...[
            // Blur Radius
            const Text(
              'Blur Radius',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _shadowBlurRadius,
                    min: 0,
                    max: 30,
                    divisions: 30,
                    label: _shadowBlurRadius.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _shadowBlurRadius = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${_shadowBlurRadius.toInt()}px'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Spread Radius
            const Text(
              'Spread Radius',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _shadowSpreadRadius,
                    min: -10,
                    max: 10,
                    divisions: 20,
                    label: _shadowSpreadRadius.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _shadowSpreadRadius = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${_shadowSpreadRadius.toInt()}px'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Offset X
            const Text(
              'Offset X',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _shadowOffsetX,
                    min: -20,
                    max: 20,
                    divisions: 40,
                    label: _shadowOffsetX.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _shadowOffsetX = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${_shadowOffsetX.toInt()}px'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Offset Y
            const Text(
              'Offset Y',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _shadowOffsetY,
                    min: -20,
                    max: 20,
                    divisions: 40,
                    label: _shadowOffsetY.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _shadowOffsetY = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${_shadowOffsetY.toInt()}px'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Opacity
            const Text(
              'Shadow Opacity',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _shadowOpacity,
                    min: 0,
                    max: 1,
                    divisions: 20,
                    label: _shadowOpacity.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _shadowOpacity = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(_shadowOpacity.toStringAsFixed(2)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Shadow Color
            const Text(
              'Shadow Color',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _shadowColorButton(Colors.black, 'Black'),
                _shadowColorButton(Colors.blue.shade900, 'Blue'),
                _shadowColorButton(Colors.red.shade900, 'Red'),
                _shadowColorButton(Colors.purple.shade900, 'Purple'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _shadowColorButton(Color color, String label) {
    final isSelected = _shadowColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _shadowColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _colorButton(Color color, String label, {bool isTextColor = false}) {
    final isSelected = isTextColor
        ? _textColor == color
        : _backgroundColor == color;

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
                  : Colors.white.withValues(alpha: 0.1);
            }
          } else {
            _backgroundColor = color;
            // Auto-adjust hover color
            if (color == Colors.white) {
              _hoverColor = const Color(0xFFE0E0E0);
            } else {
              _hoverColor = Colors.white.withValues(alpha: 0.1);
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
      padding: const EdgeInsets.all(40),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
        ),
        // ContextMenuArea wraps the separated widget
        // PlaygroundContent can use its own context since it's inside ContextMenuArea
        child: ContextMenuArea(
          child: PlaygroundContent(
            lastAction: _lastAction,
            onActionChanged: (action) => setState(() => _lastAction = action),
            config: ContextMenuConfig(
              backgroundColor: _backgroundColor,
              hoverColor: _hoverColor,
              textStyle: TextStyle(color: _textColor, fontSize: 14),
              elevation: _elevation,
              itemHeight: _itemHeight,
              minWidth: _minWidth,
              maxWidth: _maxWidth,
              animationBuilder: _selectedAnimation,
              animationDuration: Duration(
                milliseconds: _animationDuration.toInt(),
              ),
              screenPadding: EdgeInsets.only(
                top: _paddingTop,
                bottom: _paddingBottom,
                left: _paddingLeft,
                right: _paddingRight,
              ),
              itemBorderRadius: BorderRadius.circular(_itemBorderRadius),
              itemMargin: EdgeInsets.symmetric(
                horizontal: _itemMarginHorizontal,
                vertical: _itemMarginVertical,
              ),
              dividerMargin: EdgeInsets.symmetric(
                vertical: _dividerMarginVertical,
              ),
              menuPadding: EdgeInsets.symmetric(
                horizontal: _menuPaddingHorizontal,
                vertical: _menuPaddingVertical,
              ),
              boxShadow: _useCustomBoxShadow
                  ? [
                      BoxShadow(
                        color: _shadowColor.withValues(alpha: _shadowOpacity),
                        blurRadius: _shadowBlurRadius,
                        spreadRadius: _shadowSpreadRadius,
                        offset: Offset(_shadowOffsetX, _shadowOffsetY),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Second page to demonstrate ContextMenuRouteObserver in action
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Second Screen'),
      ),
      body: ContextMenuArea(
        child: GestureDetector(
          onSecondaryTapDown: (details) {
            showRootContextMenu(
              context: context,
              position: details.globalPosition,
              items: [
                ContextMenuItem(
                  label: 'Go Back',
                  icon: const Icon(Icons.arrow_back, size: 18),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ContextMenuItem.divider(),
                ContextMenuItem(
                  label: 'Action 1',
                  icon: const Icon(Icons.star, size: 18),
                  onTap: () {},
                ),
                ContextMenuItem(
                  label: 'Action 2',
                  icon: const Icon(Icons.favorite, size: 18),
                  onTap: () {},
                ),
              ],
            );
          },
          child: Container(
            color: Colors.blue.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Route Observer Test',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'How to Test:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStep('1', 'Go back to the previous screen'),
                        const SizedBox(height: 8),
                        _buildStep('2', 'Right-click to open the context menu'),
                        const SizedBox(height: 8),
                        _buildStep('3', 'Navigate here again (menu or button)'),
                        const SizedBox(height: 8),
                        _buildStep('4', 'Notice: Menu closes automatically!'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ContextMenuRouteObserver is working!',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
