import 'package:flutter/material.dart';
import '../models/context_menu_item.dart';
import '../models/context_menu_config.dart';
import '../widgets/context_menu_overlay.dart';

/// Singleton controller for managing context menu state globally.
class RootContextMenuController {
  static final RootContextMenuController _instance =
      RootContextMenuController._internal();

  factory RootContextMenuController() => _instance;

  RootContextMenuController._internal();

  /// Current active overlay entry for the menu.
  OverlayEntry? _currentMenuEntry;

  OverlayEntry? _barrierEntry;

  /// Shows a context menu at the specified position.
  void showMenu(
      {required BuildContext context,
      required Offset position,
      required List<ContextMenuItem> items,
      ContextMenuConfig? config,
      Rect? areaConstraints,
      String? title,
      bool needBarrier = false}) {
    // Close any existing menu first
    hideMenu();

    final effectiveConfig = config ?? const ContextMenuConfig();
    final overlay = Overlay.of(context);

    if (needBarrier) {
      _barrierEntry = OverlayEntry(
        builder: (_) => Positioned.fill(
          child: MouseRegion(
            opaque: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideMenu,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      overlay.insert(_barrierEntry!);
    }

    _currentMenuEntry = OverlayEntry(
      builder: (context) => ContextMenuRoot(
        position: position,
        items: items,
        config: effectiveConfig,
        areaConstraints: areaConstraints,
        title: title,
      ),
    );

    Overlay.of(context).insert(_currentMenuEntry!);
  }

  /// Hides the currently displayed menu if any.
  void hideMenu() {
    _currentMenuEntry?.remove();
    _currentMenuEntry = null;

    _barrierEntry?.remove();
    _barrierEntry = null;
  }

  /// Returns true if a menu is currently open.
  bool get isMenuOpen => _currentMenuEntry != null;
}
