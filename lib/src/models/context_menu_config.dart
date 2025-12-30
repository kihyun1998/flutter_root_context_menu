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
  });
}
