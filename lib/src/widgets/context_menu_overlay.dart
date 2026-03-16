import 'package:flutter/material.dart';
import '../models/context_menu_animation.dart';
import '../models/context_menu_config.dart';
import '../models/context_menu_item.dart';
import '../utils/menu_position_calculator.dart';
import 'context_menu_item_widget.dart';

/// Overlay widget that displays the context menu.
///
/// Uses post-frame measurement to determine the actual rendered size,
/// ensuring accurate position adjustment even with custom widget items.
class ContextMenuOverlay extends StatefulWidget {
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

  @override
  State<ContextMenuOverlay> createState() => _ContextMenuOverlayState();
}

class _ContextMenuOverlayState extends State<ContextMenuOverlay> {
  final GlobalKey _menuKey = GlobalKey();
  Offset? _adjustedPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndReposition();
    });
  }

  void _measureAndReposition() {
    final renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;

    final menuSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final newPosition = MenuPositionCalculator.calculate(
      position: widget.position,
      menuSize: menuSize,
      screenSize: screenSize,
      areaConstraints: widget.areaConstraints,
      padding: widget.config.screenPadding,
    );

    if (newPosition != widget.position) {
      setState(() {
        _adjustedPosition = newPosition;
      });
    } else {
      setState(() {
        _adjustedPosition = widget.position;
      });
    }
  }

  Widget _buildMenuContent() {
    final menuBody = Container(
      constraints: BoxConstraints(
        minWidth: widget.config.minWidth,
        maxWidth: widget.config.maxWidth,
      ),
      padding: widget.config.menuPadding,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.items
              .map(
                (item) =>
                    ContextMenuItemWidget(item: item, config: widget.config),
              )
              .toList(),
        ),
      ),
    );

    if (widget.config.boxShadow != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: widget.config.borderRadius,
          boxShadow: widget.config.boxShadow,
        ),
        child: Material(
          elevation: 0,
          borderRadius: widget.config.borderRadius,
          color: widget.config.backgroundColor,
          child: menuBody,
        ),
      );
    }

    return Material(
      elevation: widget.config.elevation,
      borderRadius: widget.config.borderRadius,
      color: widget.config.backgroundColor,
      child: menuBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPositioned = _adjustedPosition != null;
    final displayPosition = _adjustedPosition ?? widget.position;

    return Positioned(
      left: displayPosition.dx,
      top: displayPosition.dy,
      child: Opacity(
        opacity: isPositioned ? 1.0 : 0.0,
        child: TweenAnimationBuilder<double>(
          key: isPositioned ? const ValueKey('animated') : null,
          tween: Tween(begin: isPositioned ? 0.0 : 1.0, end: 1.0),
          duration:
              isPositioned ? widget.config.animationDuration : Duration.zero,
          builder: (context, value, child) {
            final animationBuilder =
                widget.config.animationBuilder ?? ContextMenuAnimations.popup;
            return animationBuilder(value, child!);
          },
          child: KeyedSubtree(
            key: _menuKey,
            child: _buildMenuContent(),
          ),
        ),
      ),
    );
  }
}
