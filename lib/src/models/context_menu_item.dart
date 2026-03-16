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
  /// Supports both sync and async callbacks.
  final Function? onTap;

  /// Whether this menu item is enabled and can be interacted with.
  final bool enabled;

  /// Custom text color for the label.
  final Color? textColor;

  /// Whether this item represents a divider (separator line).
  final bool isDivider;

  /// Whether this item uses a custom widget builder.
  final bool isCustom;

  /// Builder for custom widget content.
  ///
  /// When provided, the item renders using this builder instead of the
  /// default icon + label layout. Custom items do not auto-close the menu
  /// on interaction, allowing interactive widgets like [Switch] or [Checkbox].
  ///
  /// ```dart
  /// ContextMenuItem.custom(
  ///   builder: (context) => Row(
  ///     children: [
  ///       Icon(Icons.dark_mode, size: 18),
  ///       SizedBox(width: 8),
  ///       Text('Dark Mode'),
  ///       Spacer(),
  ///       Switch(value: isDark, onChanged: (v) { ... }),
  ///     ],
  ///   ),
  /// )
  /// ```
  final WidgetBuilder? builder;

  /// Custom height for this item. Only used for custom items.
  /// Falls back to [ContextMenuConfig.itemHeight] if null.
  final double? customHeight;

  /// Creates a context menu item.
  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.textColor,
    this.isDivider = false,
  })  : isCustom = false,
        builder = null,
        customHeight = null;

  /// Creates a divider menu item (separator line).
  const ContextMenuItem.divider()
      : label = '',
        icon = null,
        onTap = null,
        enabled = false,
        textColor = null,
        isDivider = true,
        isCustom = false,
        builder = null,
        customHeight = null;

  /// Creates a custom widget menu item.
  ///
  /// Custom items render using [builder] and do not auto-close the menu,
  /// allowing interactive widgets like [Switch], [Checkbox], or [Slider].
  const ContextMenuItem.custom({
    required WidgetBuilder this.builder,
    this.customHeight,
  })  : label = '',
        icon = null,
        onTap = null,
        enabled = true,
        textColor = null,
        isDivider = false,
        isCustom = true;
}
