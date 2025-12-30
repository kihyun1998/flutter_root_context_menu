import 'package:flutter/material.dart';

/// Defines the area where context menus can be displayed.
///
/// This widget automatically calculates its bounds and provides them
/// to descendant widgets through an InheritedWidget.
class ContextMenuArea extends StatefulWidget {
  final Widget child;

  const ContextMenuArea({
    super.key,
    required this.child,
  });

  @override
  State<ContextMenuArea> createState() => _ContextMenuAreaState();

  /// Retrieves the area bounds from the nearest [ContextMenuArea] ancestor.
  ///
  /// Returns null if no [ContextMenuArea] is found or if the RenderBox
  /// is not yet laid out.
  static Rect? of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_ContextMenuAreaProvider>();
    return provider?.getAreaBounds();
  }
}

class _ContextMenuAreaState extends State<ContextMenuArea> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _ContextMenuAreaProvider(
      areaKey: _key,
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

/// InheritedWidget that provides area bounds to descendants.
class _ContextMenuAreaProvider extends InheritedWidget {
  final GlobalKey areaKey;

  const _ContextMenuAreaProvider({
    required this.areaKey,
    required super.child,
  });

  /// Calculates and returns the global bounds of the area.
  Rect? getAreaBounds() {
    final renderBox = areaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return null;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      size.height,
    );
  }

  @override
  bool updateShouldNotify(_ContextMenuAreaProvider oldWidget) {
    return areaKey != oldWidget.areaKey;
  }
}
