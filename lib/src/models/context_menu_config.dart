import 'package:flutter/material.dart';
import 'context_menu_animation.dart';

/// Configuration for context menu appearance and behavior.
class ContextMenuConfig {
  /// Background color of the menu.
  final Color backgroundColor;

  /// Color of menu items when hovered.
  final Color hoverColor;

  /// Text style for menu item labels.
  final TextStyle textStyle;

  /// Height of each menu item.
  final double itemHeight;

  /// Minimum width of the menu.
  final double minWidth;

  /// Maximum width of the menu.
  final double maxWidth;

  /// Padding inside each menu item.
  final EdgeInsets itemPadding;

  /// Border radius of the menu container.
  final BorderRadius borderRadius;

  /// Elevation (shadow) of the menu.
  final double elevation;

  /// Duration of the menu appearance animation.
  final Duration animationDuration;

  /// Custom animation builder for the menu appearance.
  ///
  /// If null, uses the default popup animation ([ContextMenuAnimations.popup]).
  /// You can use pre-defined animations from [ContextMenuAnimations] or
  /// create your own custom animation.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   animationBuilder: ContextMenuAnimations.fade,
  /// )
  /// ```
  final ContextMenuAnimationBuilder? animationBuilder;

  /// Padding from screen edges to prevent menu from touching boundaries.
  ///
  /// This ensures the menu maintains a minimum distance from screen edges.
  /// Useful for providing visual breathing room.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   screenPadding: EdgeInsets.only(bottom: 10),
  /// )
  /// ```
  final EdgeInsets screenPadding;

  /// Border radius for individual menu items.
  ///
  /// Applies rounded corners to menu item backgrounds, especially visible
  /// when items are hovered.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   itemBorderRadius: BorderRadius.circular(6),
  /// )
  /// ```
  final BorderRadius itemBorderRadius;

  /// Margin around individual menu items.
  ///
  /// Creates spacing between the item's interactive area and the menu edges,
  /// giving a more compact and refined appearance.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   itemMargin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  /// )
  /// ```
  final EdgeInsets itemMargin;

  /// Vertical margin around dividers.
  ///
  /// Creates spacing above and below dividers, separating them from
  /// adjacent menu items.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   dividerMargin: EdgeInsets.symmetric(vertical: 4),
  /// )
  /// ```
  final EdgeInsets dividerMargin;

  /// Padding inside the menu container.
  ///
  /// Creates spacing between the menu's edge and its contents (items).
  /// This padding is applied to the entire menu container.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   menuPadding: EdgeInsets.symmetric(vertical: 8),
  /// )
  /// ```
  final EdgeInsets menuPadding;

  /// Width of icons in menu items.
  ///
  /// When set to a value > 0, icons will be constrained to this width
  /// and used for accurate menu width calculation.
  /// When 0 (default), icons use their natural size.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   iconWidth: 18.0,
  ///   iconSpacing: 12.0,
  /// )
  /// ```
  final double iconWidth;

  /// Spacing between icon and label text.
  ///
  /// Only applied when [iconWidth] > 0.
  final double iconSpacing;

  /// Custom box shadow for the menu.
  ///
  /// When provided, this shadow will be used instead of [elevation].
  /// If null, [elevation] will be used to generate a default shadow.
  ///
  /// Example:
  /// ```dart
  /// ContextMenuConfig(
  ///   boxShadow: [
  ///     BoxShadow(
  ///       color: Colors.black.withOpacity(0.2),
  ///       blurRadius: 10,
  ///       offset: Offset(0, 4),
  ///     ),
  ///   ],
  /// )
  /// ```
  final List<BoxShadow>? boxShadow;

  /// Delay before a submenu opens when hovering over a submenu item.
  ///
  /// A short delay prevents submenus from flickering open during casual
  /// mouse movement across menu items.
  final Duration submenuOpenDelay;

  /// Delay before a submenu closes after the mouse leaves.
  ///
  /// This delay allows the user to move the mouse from the parent item
  /// to the submenu panel across the gap without the submenu closing.
  final Duration submenuCloseDelay;

  /// Horizontal offset between the parent menu and submenu.
  ///
  /// Negative values create a slight overlap between menus, which helps
  /// prevent hover gaps when moving the mouse between parent and submenu.
  final double submenuHorizontalOffset;

  /// Custom animation builder for submenu appearance.
  ///
  /// If null, automatically uses [ContextMenuAnimations.slideRight] when
  /// the submenu opens to the right, or slideLeft when it opens to the left.
  final ContextMenuAnimationBuilder? submenuAnimationBuilder;

  /// Duration of the submenu appearance animation.
  ///
  /// If null, falls back to [animationDuration].
  final Duration? submenuAnimationDuration;

  /// Maximum submenu nesting depth to prevent infinite recursion.
  ///
  /// When the depth limit is reached, submenu items at that level will
  /// not open further submenus.
  final int maxSubmenuDepth;

  /// Creates a context menu configuration with customizable styling.
  const ContextMenuConfig({
    this.backgroundColor = Colors.white,
    this.hoverColor = const Color(0xFFE0E0E0),
    this.textStyle = const TextStyle(fontSize: 14),
    this.itemHeight = 40.0,
    this.minWidth = 180.0,
    this.maxWidth = 280.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationBuilder,
    this.screenPadding = EdgeInsets.zero,
    this.itemBorderRadius = BorderRadius.zero,
    this.itemMargin = EdgeInsets.zero,
    this.dividerMargin = EdgeInsets.zero,
    this.menuPadding = EdgeInsets.zero,
    this.iconWidth = 0,
    this.iconSpacing = 0,
    this.boxShadow,
    this.submenuOpenDelay = const Duration(milliseconds: 200),
    this.submenuCloseDelay = const Duration(milliseconds: 300),
    this.submenuHorizontalOffset = -4.0,
    this.submenuAnimationBuilder,
    this.submenuAnimationDuration,
    this.maxSubmenuDepth = 5,
  });
}
