import 'package:flutter/widgets.dart';

import 'controller/context_menu_controller.dart';
import 'models/context_menu_config.dart';
import 'models/context_menu_item.dart';
import 'widgets/context_menu_area.dart';

/// Shows a context menu at the specified position.
///
/// This is a convenience function that automatically retrieves
/// the area constraints from the nearest [ContextMenuArea] ancestor.
///
/// Example:
/// ```dart
/// GestureDetector(
///   onSecondaryTapDown: (details) {
///     showRootContextMenu(
///       context: context,
///       position: details.globalPosition,
///       items: [
///         ContextMenuItem(label: 'Copy', onTap: () {}),
///         ContextMenuItem(label: 'Paste', onTap: () {}),
///       ],
///     );
///   },
///   child: Text('Right click me'),
/// )
/// ```
void showRootContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuItem> items,
  ContextMenuConfig? config,
}) {
  // Get area constraints from the nearest ContextMenuArea
  final areaConstraints = ContextMenuArea.of(context);

  RootContextMenuController().showMenu(
    context: context,
    position: position,
    items: items,
    config: config,
    areaConstraints: areaConstraints,
  );
}

/// Closes the currently open context menu if any.
///
/// This is a convenience function that explicitly closes any active context menu.
/// Useful when you need to programmatically close the menu, such as:
/// - Before navigating to a new screen
/// - When handling custom gestures or events
/// - When the app state changes and the menu should be dismissed
///
/// Example:
/// ```dart
/// // Close menu before navigation
/// closeRootContextMenu();
/// Navigator.push(context, MaterialPageRoute(builder: (_) => NewPage()));
///
/// // Close menu on custom event
/// void onCustomEvent() {
///   closeRootContextMenu();
///   // Handle event...
/// }
/// ```
///
/// Note: The menu is automatically closed when:
/// - User clicks outside the menu
/// - User selects a menu item
/// - Navigation routes change (if ContextMenuRouteObserver is registered)
void closeRootContextMenu() {
  RootContextMenuController().hideMenu();
}

/// Checks if a context menu is currently open.
///
/// Returns `true` if a menu is currently displayed, `false` otherwise.
///
/// Example:
/// ```dart
/// if (isRootContextMenuOpen()) {
///   print('Menu is open');
///   closeRootContextMenu();
/// }
/// ```
bool isRootContextMenuOpen() {
  return RootContextMenuController().isMenuOpen;
}
