import 'package:flutter/material.dart';
import 'context_menu_animation.dart';

/// Configuration for submenu behavior and appearance.
class SubmenuConfig {
  /// Delay before a submenu opens when hovering over a submenu item.
  ///
  /// A short delay prevents submenus from flickering open during casual
  /// mouse movement across menu items.
  final Duration openDelay;

  /// Delay before a submenu closes after the mouse leaves.
  ///
  /// This delay allows the user to move the mouse from the parent item
  /// to the submenu panel across the gap without the submenu closing.
  final Duration closeDelay;

  /// Horizontal offset between the parent menu and submenu.
  ///
  /// Negative values create a slight overlap between menus, which helps
  /// prevent hover gaps when moving the mouse between parent and submenu.
  final double horizontalOffset;

  /// Custom animation builder for submenu appearance.
  ///
  /// If null, automatically uses [ContextMenuAnimations.slideRight] when
  /// the submenu opens to the right, or slideLeft when it opens to the left.
  final ContextMenuAnimationBuilder? animationBuilder;

  /// Duration of the submenu appearance animation.
  ///
  /// If null, falls back to [ContextMenuConfig.animationDuration].
  final Duration? animationDuration;

  /// Maximum submenu nesting depth to prevent infinite recursion.
  ///
  /// When the depth limit is reached, submenu items at that level will
  /// not open further submenus.
  final int maxDepth;

  /// Custom icon widget displayed on the right side of submenu items.
  ///
  /// Defaults to a chevron right icon when null.
  ///
  /// Example:
  /// ```dart
  /// SubmenuConfig(
  ///   icon: Icon(Icons.arrow_right, size: 14, color: Colors.blue),
  /// )
  /// ```
  final Widget? icon;

  /// Creates a submenu configuration with customizable behavior.
  const SubmenuConfig({
    this.openDelay = const Duration(milliseconds: 200),
    this.closeDelay = const Duration(milliseconds: 300),
    this.horizontalOffset = -4.0,
    this.animationBuilder,
    this.animationDuration,
    this.maxDepth = 5,
    this.icon,
  });
}
