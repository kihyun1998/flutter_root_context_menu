import 'package:flutter/material.dart';

/// Defines the area where context menus can be displayed.
///
/// This widget automatically calculates its bounds and provides them
/// to descendant widgets through an InheritedWidget.
///
/// You can use either [child] or [builder]:
/// - [child]: Simple usage, but you must ensure the correct context is passed
///   to [showContextMenu] (e.g., using a [Builder] widget).
/// - [builder]: Recommended. Provides the correct context automatically.
///
/// Example with builder:
/// ```dart
/// ContextMenuArea(
///   builder: (context) => GestureDetector(
///     onSecondaryTapDown: (details) {
///       showRootContextMenu(
///         context: context,  // This context is inside ContextMenuArea
///         position: details.globalPosition,
///         items: [...],
///       );
///     },
///     child: YourWidget(),
///   ),
/// )
/// ```
class ContextMenuArea extends StatefulWidget {
  /// The child widget. Use this for simple cases.
  ///
  /// Note: When using [child], ensure you pass the correct context to
  /// [showRootContextMenu]. The context must be from inside this [ContextMenuArea].
  final Widget? child;

  /// Builder that provides the correct context for [showRootContextMenu].
  ///
  /// This is the recommended way to use [ContextMenuArea] as it ensures
  /// the menu respects the area boundaries.
  final Widget Function(BuildContext context)? builder;

  const ContextMenuArea({
    super.key,
    this.child,
    this.builder,
  })  : assert(
          child != null || builder != null,
          'Either child or builder must be provided',
        ),
        assert(
          child == null || builder == null,
          'Cannot provide both child and builder',
        );

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
        child: widget.builder != null
            ? Builder(builder: widget.builder!)
            : widget.child,
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
