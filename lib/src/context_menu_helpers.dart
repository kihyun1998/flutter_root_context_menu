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
