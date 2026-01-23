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
    // Calculate menu size including all margins and paddings

    int dividerCount = items.where((item) => item.isDivider).length;
    int normalItemCount = items.length - dividerCount;

    // Height calculation:
    // - Normal items: height + vertical margins
    // - Dividers: divider height (1px) + vertical margins
    // - Menu padding: top + bottom
    double itemsHeight = normalItemCount * config.itemHeight;
    double itemMarginsHeight =
        normalItemCount * (config.itemMargin.top + config.itemMargin.bottom);

    double dividersHeight = dividerCount * 1.0; // Divider height is 1px
    double dividerMarginsHeight =
        dividerCount * (config.dividerMargin.top + config.dividerMargin.bottom);

    double height = itemsHeight +
        itemMarginsHeight +
        dividersHeight +
        dividerMarginsHeight +
        config.menuPadding.top +
        config.menuPadding.bottom;

    // Width calculation: based on actual content width
    double contentWidth = _calculateContentWidth();
    double width = contentWidth.clamp(config.minWidth, config.maxWidth) +
        config.menuPadding.left +
        config.menuPadding.right;

    return Size(width, height);
  }

  /// Calculates the actual content width based on the longest item.
  double _calculateContentWidth() {
    double maxContentWidth = 0;

    for (final item in items) {
      if (item.isDivider) continue;

      // Calculate text width using TextPainter
      final textPainter = TextPainter(
        text: TextSpan(text: item.label, style: config.textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      double itemWidth = textPainter.width;

      // Add icon width + spacing (only if configured)
      if (item.icon != null && config.iconWidth > 0) {
        itemWidth += config.iconWidth + config.iconSpacing;
      }

      // Add item padding (horizontal)
      itemWidth += config.itemPadding.left + config.itemPadding.right;

      // Add item margin (horizontal)
      itemWidth += config.itemMargin.left + config.itemMargin.right;

      if (itemWidth > maxContentWidth) {
        maxContentWidth = itemWidth;
      }
    }

    return maxContentWidth;
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
      padding: config.screenPadding,
    );

    return Positioned(
      left: adjustedPosition.dx,
      top: adjustedPosition.dy,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          // Absorb pointer events to prevent closing the menu
          // when clicking on menu items
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: config.animationDuration,
          builder: (context, value, child) {
            // Use custom animation builder if provided, otherwise use default popup
            final animationBuilder =
                config.animationBuilder ?? ContextMenuAnimations.popup;
            return animationBuilder(value, child!);
          },
          child: config.boxShadow != null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: config.borderRadius,
                    boxShadow: config.boxShadow,
                  ),
                  child: Material(
                    elevation: 0,
                    borderRadius: config.borderRadius,
                    color: config.backgroundColor,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: config.minWidth,
                        maxWidth: config.maxWidth,
                      ),
                      padding: config.menuPadding,
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: items
                              .map(
                                (item) => ContextMenuItemWidget(
                                    item: item, config: config),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                )
              : Material(
                  elevation: config.elevation,
                  borderRadius: config.borderRadius,
                  color: config.backgroundColor,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: config.minWidth,
                      maxWidth: config.maxWidth,
                    ),
                    padding: config.menuPadding,
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: items
                            .map(
                              (item) => ContextMenuItemWidget(
                                  item: item, config: config),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
        ), // TweenAnimationBuilder
      ), // Listener
    ); // Positioned
  }
}
