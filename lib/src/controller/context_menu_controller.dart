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

  /// Shows a context menu at the specified position.
  void showMenu({
    required BuildContext context,
    required Offset position,
    required List<ContextMenuItem> items,
    ContextMenuConfig? config,
    Rect? areaConstraints,
  }) {
    // Close any existing menu first
    hideMenu();

    final effectiveConfig = config ?? const ContextMenuConfig();

    _currentMenuEntry = OverlayEntry(
      builder: (context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          final menuToClose =
              _currentMenuEntry; // Capture current menu instance
          // Close the menu when clicking outside
          // Event continues to propagate to widgets below
          // Delay hideMenu to next frame so GestureDetector's onTap can execute first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Only hide if it's the same menu instance (not replaced by a new menu)
            if (_currentMenuEntry != null && _currentMenuEntry == menuToClose) {
              hideMenu();
            }
          });
        },
        child: Stack(
          children: [
            // The actual menu
            ContextMenuOverlay(
              position: position,
              items: items,
              config: effectiveConfig,
              areaConstraints: areaConstraints,
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_currentMenuEntry!);
  }

  /// Hides the currently displayed menu if any.
  void hideMenu() {
    _currentMenuEntry?.remove();
    _currentMenuEntry = null;
  }

  /// Returns true if a menu is currently open.
  bool get isMenuOpen => _currentMenuEntry != null;
}
