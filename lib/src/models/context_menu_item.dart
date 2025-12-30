import 'package:flutter/widgets.dart';

/// Represents a single item in a context menu.
class ContextMenuItem {
  /// The label text displayed for this menu item.
  final String label;

  /// Optional icon widget displayed before the label.
  ///
  /// Can be any widget like [Icon], [SvgPicture], or custom widgets.
  /// For standard Material icons:
  /// ```dart
  /// icon: Icon(Icons.copy, size: 18)
  /// ```
  final Widget? icon;

  /// Callback function executed when the item is tapped.
  final VoidCallback? onTap;

  /// Whether this menu item is enabled and can be interacted with.
  final bool enabled;

  /// Custom text color for the label.
  final Color? textColor;

  /// Whether this item represents a divider (separator line).
  final bool isDivider;

  /// Creates a context menu item.
  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.textColor,
    this.isDivider = false,
  });

  /// Creates a divider menu item (separator line).
  const ContextMenuItem.divider()
      : label = '',
        icon = null,
        onTap = null,
        enabled = false,
        textColor = null,
        isDivider = true;
}
