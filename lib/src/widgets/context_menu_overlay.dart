import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/context_menu_controller.dart';
import '../models/context_menu_animation.dart';
import '../models/context_menu_config.dart';
import '../models/context_menu_item.dart';
import '../utils/menu_position_calculator.dart';
import 'context_menu_item_widget.dart';

/// Represents one level in the menu stack (root or submenu).
class _MenuLevel {
  final List<ContextMenuItem> items;
  Offset position;
  final int parentItemIndex;
  bool measured;
  final GlobalKey menuKey;
  final GlobalKey? triggerItemKey;
  bool openedLeft;

  _MenuLevel({
    required this.items,
    required this.position,
    this.parentItemIndex = -1,
    GlobalKey? menuKey,
    this.triggerItemKey,
  })  : menuKey = menuKey ?? GlobalKey(),
        measured = false,
        openedLeft = false;
}

/// Root widget managing the entire context menu tree (root + submenus).
///
/// Placed directly inside the [OverlayEntry] created by the controller.
/// Manages the menu stack, hover timers, and post-frame measurement.
class ContextMenuRoot extends StatefulWidget {
  final Offset position;
  final List<ContextMenuItem> items;
  final ContextMenuConfig config;
  final Rect? areaConstraints;
  final String? title;

  const ContextMenuRoot({
    super.key,
    required this.position,
    required this.items,
    required this.config,
    this.areaConstraints,
    this.title,
  });

  @override
  State<ContextMenuRoot> createState() => _ContextMenuRootState();
}

class _ContextMenuRootState extends State<ContextMenuRoot> {
  final List<_MenuLevel> _menuStack = [];
  Timer? _openTimer;
  final Map<int, Timer> _closeTimers = {};

  @override
  void initState() {
    super.initState();
    // Initialize root menu
    final rootLevel = _MenuLevel(
      items: widget.items,
      position: widget.position,
    );
    _menuStack.add(rootLevel);
    _schedulePostFrameMeasurement(0);
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    for (final timer in _closeTimers.values) {
      timer.cancel();
    }
    _closeTimers.clear();
    super.dispose();
  }

  // -- Timer management --

  void _setCloseTimer(int depth, Timer timer) {
    _closeTimers[depth]?.cancel();
    _closeTimers[depth] = timer;
  }

  void _cancelCloseTimer(int depth) {
    _closeTimers[depth]?.cancel();
    _closeTimers.remove(depth);
  }

  void _cancelOpenTimer() {
    _openTimer?.cancel();
    _openTimer = null;
  }

  // -- Post-frame measurement --

  void _schedulePostFrameMeasurement(int depth) {
    final expectedMenuKey = _menuStack[depth].menuKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (depth >= _menuStack.length) return;
      if (_menuStack[depth].menuKey != expectedMenuKey) return;

      final renderBox =
          expectedMenuKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      _handlePanelMeasured(depth, renderBox);
    });
  }

  void _handlePanelMeasured(int depth, RenderBox menuRenderBox) {
    final level = _menuStack[depth];
    final menuSize = menuRenderBox.size;
    final screenSize = MediaQuery.of(context).size;

    if (depth == 0) {
      final newPos = MenuPositionCalculator.calculate(
        position: widget.position,
        menuSize: menuSize,
        screenSize: screenSize,
        areaConstraints: widget.areaConstraints,
        padding: widget.config.screenPadding,
      );
      setState(() {
        level.position = newPos;
        level.measured = true;
      });
    } else {
      // Submenu: need parent panel bounds and trigger item bounds
      final parentLevel = _menuStack[depth - 1];
      final parentRenderBox =
          parentLevel.menuKey.currentContext?.findRenderObject() as RenderBox?;
      if (parentRenderBox == null) return;

      final parentBounds =
          parentRenderBox.localToGlobal(Offset.zero) & parentRenderBox.size;

      final triggerRenderBox = level.triggerItemKey?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (triggerRenderBox == null) return;

      final triggerItemBounds =
          triggerRenderBox.localToGlobal(Offset.zero) & triggerRenderBox.size;

      final newPos = MenuPositionCalculator.calculateSubmenu(
        parentPanelBounds: parentBounds,
        triggerItemBounds: triggerItemBounds,
        submenuSize: menuSize,
        screenSize: screenSize,
        areaConstraints: widget.areaConstraints,
        padding: widget.config.screenPadding,
        horizontalOffset: widget.config.submenu.horizontalOffset,
      );

      final openedLeft = newPos.dx < parentBounds.left;

      setState(() {
        level.position = newPos;
        level.measured = true;
        level.openedLeft = openedLeft;
      });
    }
  }

  // -- Submenu open/close logic --

  void _closeSubmenusFrom(int depth) {
    if (depth >= _menuStack.length) return;
    // Cancel any close timers for removed depths
    for (int i = depth; i < _menuStack.length; i++) {
      _cancelCloseTimer(i);
    }
    setState(() {
      _menuStack.removeRange(depth, _menuStack.length);
    });
  }

  void _openSubmenu(int parentDepth, int itemIndex, GlobalKey triggerItemKey,
      List<ContextMenuItem> children) {
    if (!mounted) return;
    // Enforce max depth
    if (parentDepth + 1 >= widget.config.submenu.maxDepth) return;

    // Close any existing deeper submenus
    _closeSubmenusFrom(parentDepth + 1);

    final newLevel = _MenuLevel(
      items: children,
      position: Offset.zero, // Will be adjusted after measurement
      parentItemIndex: itemIndex,
      triggerItemKey: triggerItemKey,
    );

    setState(() {
      _menuStack.add(newLevel);
    });

    _schedulePostFrameMeasurement(parentDepth + 1);
  }

  // -- Hover handlers --

  void _handleSubmenuItemHover(int depth, int itemIndex,
      GlobalKey triggerItemKey, List<ContextMenuItem> children) {
    // Cancel close timer for the submenu that would open
    _cancelCloseTimer(depth + 1);

    // If same submenu is already open, do nothing
    if (depth + 1 < _menuStack.length &&
        _menuStack[depth + 1].parentItemIndex == itemIndex) {
      _cancelOpenTimer();
      return;
    }

    // If a different submenu is open at this depth, close it immediately
    if (depth + 1 < _menuStack.length) {
      _closeSubmenusFrom(depth + 1);
    }

    // Schedule opening
    _cancelOpenTimer();
    _openTimer = Timer(widget.config.submenu.openDelay, () {
      if (!mounted) return;
      _openSubmenu(depth, itemIndex, triggerItemKey, children);
    });
  }

  void _handleSubmenuItemUnhover(int depth, int itemIndex) {
    _setCloseTimer(
      depth + 1,
      Timer(widget.config.submenu.closeDelay, () {
        if (!mounted) return;
        _closeSubmenusFrom(depth + 1);
      }),
    );
  }

  void _handleNonSubmenuItemHover(int depth) {
    _cancelOpenTimer();
    _closeSubmenusFrom(depth + 1);
  }

  void _handlePanelEnter(int depth) {
    // Cancel close timers for this panel and all ancestor panels.
    // When mouse moves from depth 1 → depth 2, depth 1's exit timer
    // must also be cancelled, otherwise the parent closes everything.
    for (int i = 1; i <= depth; i++) {
      _cancelCloseTimer(i);
    }
  }

  void _handlePanelExit(int depth) {
    // Only schedule close for submenus (depth > 0), not root
    if (depth == 0) return;
    _setCloseTimer(
      depth,
      Timer(widget.config.submenu.closeDelay, () {
        if (!mounted) return;
        _closeSubmenusFrom(depth);
      }),
    );
  }

  int? _getActiveChildIndex(int depth) {
    if (depth + 1 < _menuStack.length) {
      return _menuStack[depth + 1].parentItemIndex;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen transparent layer to detect clicks outside menu
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => RootContextMenuController().hideMenu(),
            child: const IgnorePointer(),
          ),
        ),
        // Menu panels
        for (var i = 0; i < _menuStack.length; i++)
          _ContextMenuPanel(
            menuKey: _menuStack[i].menuKey,
            items: _menuStack[i].items,
            position: _menuStack[i].position,
            config: widget.config,
            title: i == 0 ? widget.title : null,
            depth: i,
            measured: _menuStack[i].measured,
            openedLeft: _menuStack[i].openedLeft,
            activeChildIndex: _getActiveChildIndex(i),
            onSubmenuItemHoverEnter: (itemIndex, itemKey, children) =>
                _handleSubmenuItemHover(i, itemIndex, itemKey, children),
            onSubmenuItemHoverExit: (itemIndex) =>
                _handleSubmenuItemUnhover(i, itemIndex),
            onNonSubmenuItemHoverEnter: () => _handleNonSubmenuItemHover(i),
            onPanelMouseEnter: () => _handlePanelEnter(i),
            onPanelMouseExit: () => _handlePanelExit(i),
          ),
      ],
    );
  }
}

/// Renders a single menu panel (root or submenu).
class _ContextMenuPanel extends StatelessWidget {
  final GlobalKey menuKey;
  final List<ContextMenuItem> items;
  final Offset position;
  final ContextMenuConfig config;
  final String? title;
  final int depth;
  final bool measured;
  final bool openedLeft;
  final int? activeChildIndex;
  final void Function(
          int itemIndex, GlobalKey itemKey, List<ContextMenuItem> children)
      onSubmenuItemHoverEnter;
  final void Function(int itemIndex) onSubmenuItemHoverExit;
  final VoidCallback onNonSubmenuItemHoverEnter;
  final VoidCallback onPanelMouseEnter;
  final VoidCallback onPanelMouseExit;

  const _ContextMenuPanel({
    required this.menuKey,
    required this.items,
    required this.position,
    required this.config,
    required this.title,
    required this.depth,
    required this.measured,
    required this.openedLeft,
    required this.activeChildIndex,
    required this.onSubmenuItemHoverEnter,
    required this.onSubmenuItemHoverExit,
    required this.onNonSubmenuItemHoverEnter,
    required this.onPanelMouseEnter,
    required this.onPanelMouseExit,
  });

  ContextMenuAnimationBuilder _resolveAnimationBuilder() {
    if (depth == 0) {
      return config.animationBuilder ?? ContextMenuAnimations.popup;
    }
    if (config.submenu.animationBuilder != null) {
      return config.submenu.animationBuilder!;
    }
    return openedLeft
        ? ContextMenuAnimations.slideLeft
        : ContextMenuAnimations.slideRight;
  }

  Widget _buildMenuContent() {
    final menuBody = Container(
      constraints: BoxConstraints(
        minWidth: config.minWidth,
        maxWidth: config.maxWidth,
      ),
      padding: config.menuPadding,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Padding(
                padding: config.titlePadding,
                child: Text(
                  title!,
                  style: config.titleStyle,
                ),
              ),
              Padding(
                padding: config.dividerMargin,
                child: const Divider(height: 1, thickness: 1),
              ),
            ],
            for (var i = 0; i < items.length; i++)
              ContextMenuItemWidget(
                item: items[i],
                config: config,
                itemIndex: i,
                isActiveSubmenuParent: activeChildIndex == i,
                onSubmenuHoverEnter: items[i].isSubmenu
                    ? (itemKey) =>
                        onSubmenuItemHoverEnter(i, itemKey, items[i].children!)
                    : null,
                onSubmenuHoverExit:
                    items[i].isSubmenu ? () => onSubmenuItemHoverExit(i) : null,
                onNonSubmenuItemHoverEnter: !items[i].isSubmenu &&
                        !items[i].isDivider &&
                        !items[i].isCustom
                    ? () => onNonSubmenuItemHoverEnter()
                    : null,
              ),
          ],
        ),
      ),
    );

    if (config.boxShadow != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: config.borderRadius,
          boxShadow: config.boxShadow,
        ),
        child: Material(
          elevation: 0,
          borderRadius: config.borderRadius,
          color: config.backgroundColor,
          child: menuBody,
        ),
      );
    }

    return Material(
      elevation: config.elevation,
      borderRadius: config.borderRadius,
      color: config.backgroundColor,
      child: menuBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Opacity(
        opacity: measured ? 1.0 : 0.0,
        child: MouseRegion(
          onEnter: (_) => onPanelMouseEnter(),
          onExit: (_) => onPanelMouseExit(),
          child: TweenAnimationBuilder<double>(
            key: measured ? const ValueKey('animated') : null,
            tween: Tween(begin: measured ? 0.0 : 1.0, end: 1.0),
            duration: measured
                ? (depth > 0 && config.submenu.animationDuration != null
                    ? config.submenu.animationDuration!
                    : config.animationDuration)
                : Duration.zero,
            builder: (context, value, child) {
              final animationBuilder = _resolveAnimationBuilder();
              return animationBuilder(value, child!);
            },
            child: KeyedSubtree(
              key: menuKey,
              child: _buildMenuContent(),
            ),
          ),
        ),
      ),
    );
  }
}
