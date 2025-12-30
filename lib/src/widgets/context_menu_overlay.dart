import 'package:flutter/material.dart';
import '../models/context_menu_animation.dart';
import '../models/context_menu_config.dart';
import '../models/context_menu_item.dart';
import '../utils/menu_position_calculator.dart';
import 'context_menu_item_widget.dart';

/// Overlay widget that displays the context menu.
class ContextMenuOverlay extends StatelessWidget {
  final Offset position;
  final List<ContextMenuItem> items;
  final ContextMenuConfig config;
  final Rect? areaConstraints;

  const ContextMenuOverlay({
    super.key,
    required this.position,
    required this.items,
    required this.config,
    this.areaConstraints,
  });

  /// Calculates the menu size based on items.
  Size _calculateMenuSize() {
    // Approximate menu size
    // Width: from config
    // Height: number of items * item height + dividers

    int dividerCount = items.where((item) => item.isDivider).length;
    int normalItemCount = items.length - dividerCount;

    double height =
        (normalItemCount * config.itemHeight) + dividerCount.toDouble();

    return Size(config.maxWidth, height);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final menuSize = _calculateMenuSize();

    final adjustedPosition = MenuPositionCalculator.calculate(
      position: position,
      menuSize: menuSize,
      screenSize: screenSize,
      areaConstraints: areaConstraints,
    );

    return Positioned(
      left: adjustedPosition.dx,
      top: adjustedPosition.dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: config.animationDuration,
        builder: (context, value, child) {
          // Use custom animation builder if provided, otherwise use default popup
          final animationBuilder =
              config.animationBuilder ?? ContextMenuAnimations.popup;
          return animationBuilder(value, child!);
        },
        child: Material(
          elevation: config.elevation,
          borderRadius: config.borderRadius,
          color: config.backgroundColor,
          child: Container(
            constraints: BoxConstraints(
              minWidth: config.minWidth,
              maxWidth: config.maxWidth,
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items
                    .map(
                      (item) =>
                          ContextMenuItemWidget(item: item, config: config),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
