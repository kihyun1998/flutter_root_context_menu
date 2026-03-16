import 'package:flutter/material.dart';

import '../models/playground_settings.dart';

class ControlPanel extends StatelessWidget {
  final PlaygroundSettings settings;
  final VoidCallback onChanged;

  const ControlPanel({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  void _update(void Function() mutation) {
    mutation();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
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
          _buildAnimationSection(),
          _buildStyleSection(),
          _buildScreenPaddingSection(),
          _buildItemStylingSection(),
          _buildDividerMenuSection(),
          _buildBoxShadowSection(),
        ],
      ),
    );
  }

  Widget _buildAnimationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animation Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: settings.animationName,
          isExpanded: true,
          items: PlaygroundSettings.animations.keys.map((name) {
            return DropdownMenuItem(value: name, child: Text(name));
          }).toList(),
          onChanged: (value) {
            _update(() {
              settings.animationName = value!;
              settings.selectedAnimation =
                  PlaygroundSettings.animations[value]!;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Animation Duration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSliderRow(
          value: settings.animationDuration,
          min: 0,
          max: 1000,
          divisions: 20,
          label: '${settings.animationDuration.toInt()}ms',
          suffix: '${settings.animationDuration.toInt()}ms',
          onChanged: (v) => _update(() => settings.animationDuration = v),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const Text('Elevation', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSliderRow(
          value: settings.elevation,
          min: 0,
          max: 24,
          divisions: 12,
          onChanged: (v) => _update(() => settings.elevation = v),
        ),
        const SizedBox(height: 20),
        const Text(
          'Item Height',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSliderRow(
          value: settings.itemHeight,
          min: 30,
          max: 60,
          divisions: 6,
          onChanged: (v) => _update(() => settings.itemHeight = v),
        ),
        const SizedBox(height: 20),
        const Text('Min Width', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSliderRow(
          value: settings.minWidth,
          min: 100,
          max: 400,
          divisions: 30,
          onChanged: (v) => _update(() {
            settings.minWidth = v;
            if (settings.minWidth > settings.maxWidth) {
              settings.maxWidth = settings.minWidth;
            }
          }),
        ),
        const SizedBox(height: 20),
        const Text('Max Width', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSliderRow(
          value: settings.maxWidth,
          min: 100,
          max: 400,
          divisions: 30,
          onChanged: (v) => _update(() {
            settings.maxWidth = v;
            if (settings.maxWidth < settings.minWidth) {
              settings.minWidth = settings.maxWidth;
            }
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScreenPaddingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Screen Padding',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildPaddingSlider(
          'Top',
          settings.paddingTop,
          (v) => _update(() => settings.paddingTop = v),
        ),
        _buildPaddingSlider(
          'Bottom',
          settings.paddingBottom,
          (v) => _update(() => settings.paddingBottom = v),
        ),
        _buildPaddingSlider(
          'Left',
          settings.paddingLeft,
          (v) => _update(() => settings.paddingLeft = v),
        ),
        _buildPaddingSlider(
          'Right',
          settings.paddingRight,
          (v) => _update(() => settings.paddingRight = v),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildItemStylingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Styling',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Text(
          'Border Radius',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.itemBorderRadius,
          min: 0,
          max: 20,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.itemBorderRadius.toInt()}px',
          onChanged: (v) => _update(() => settings.itemBorderRadius = v),
        ),
        const SizedBox(height: 12),
        const Text(
          'Margin Horizontal',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.itemMarginHorizontal,
          min: 0,
          max: 20,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.itemMarginHorizontal.toInt()}px',
          onChanged: (v) => _update(() => settings.itemMarginHorizontal = v),
        ),
        const SizedBox(height: 12),
        const Text(
          'Margin Vertical',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.itemMarginVertical,
          min: 0,
          max: 10,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.itemMarginVertical.toInt()}px',
          onChanged: (v) => _update(() => settings.itemMarginVertical = v),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDividerMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Divider & Menu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Text(
          'Divider Margin Vertical',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.dividerMarginVertical,
          min: 0,
          max: 20,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.dividerMarginVertical.toInt()}px',
          onChanged: (v) => _update(() => settings.dividerMarginVertical = v),
        ),
        const SizedBox(height: 12),
        const Text(
          'Menu Padding Horizontal',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.menuPaddingHorizontal,
          min: 0,
          max: 20,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.menuPaddingHorizontal.toInt()}px',
          onChanged: (v) => _update(() => settings.menuPaddingHorizontal = v),
        ),
        const SizedBox(height: 12),
        const Text(
          'Menu Padding Vertical',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: settings.menuPaddingVertical,
          min: 0,
          max: 20,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${settings.menuPaddingVertical.toInt()}px',
          onChanged: (v) => _update(() => settings.menuPaddingVertical = v),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBoxShadowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Box Shadow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Use Custom Shadow',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Switch(
              value: settings.useCustomBoxShadow,
              onChanged: (v) => _update(() => settings.useCustomBoxShadow = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (settings.useCustomBoxShadow) ...[
          _buildLabeledSlider(
            'Blur Radius',
            settings.shadowBlurRadius,
            0,
            30,
            30,
            '${settings.shadowBlurRadius.toInt()}px',
            (v) => _update(() => settings.shadowBlurRadius = v),
          ),
          _buildLabeledSlider(
            'Spread Radius',
            settings.shadowSpreadRadius,
            -10,
            10,
            20,
            '${settings.shadowSpreadRadius.toInt()}px',
            (v) => _update(() => settings.shadowSpreadRadius = v),
          ),
          _buildLabeledSlider(
            'Offset X',
            settings.shadowOffsetX,
            -20,
            20,
            40,
            '${settings.shadowOffsetX.toInt()}px',
            (v) => _update(() => settings.shadowOffsetX = v),
          ),
          _buildLabeledSlider(
            'Offset Y',
            settings.shadowOffsetY,
            -20,
            20,
            40,
            '${settings.shadowOffsetY.toInt()}px',
            (v) => _update(() => settings.shadowOffsetY = v),
          ),
          _buildLabeledSlider(
            'Shadow Opacity',
            settings.shadowOpacity,
            0,
            1,
            20,
            settings.shadowOpacity.toStringAsFixed(2),
            (v) => _update(() => settings.shadowOpacity = v),
          ),
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
    );
  }

  // --- Helper widgets ---

  Widget _buildSliderRow({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    String? label,
    String? suffix,
    double suffixWidth = 50,
  }) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label ?? value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: suffixWidth,
          child: Text(suffix ?? value.toInt().toString()),
        ),
      ],
    );
  }

  Widget _buildPaddingSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          suffixWidth: 40,
          suffix: '${value.toInt()}px',
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLabeledSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    String suffix,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        _buildSliderRow(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          suffixWidth: 40,
          suffix: suffix,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _colorButton(Color color, String label, {bool isTextColor = false}) {
    final isSelected = isTextColor
        ? settings.textColor == color
        : settings.backgroundColor == color;

    return GestureDetector(
      onTap: () {
        _update(() {
          if (isTextColor) {
            settings.textColor = color;
            if (color == Colors.white) {
              settings.hoverColor = Colors.grey.shade700;
            } else {
              settings.hoverColor = settings.backgroundColor == Colors.white
                  ? const Color(0xFFE0E0E0)
                  : Colors.white.withValues(alpha: 0.1);
            }
          } else {
            settings.backgroundColor = color;
            if (color == Colors.white) {
              settings.hoverColor = const Color(0xFFE0E0E0);
            } else {
              settings.hoverColor = Colors.white.withValues(alpha: 0.1);
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

  Widget _shadowColorButton(Color color, String label) {
    final isSelected = settings.shadowColor == color;

    return GestureDetector(
      onTap: () => _update(() => settings.shadowColor = color),
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
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
