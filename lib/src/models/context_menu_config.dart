import 'package:flutter/material.dart';

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

  /// Padding inside each menu item.
  final EdgeInsets itemPadding;

  /// Border radius of the menu container.
  final BorderRadius borderRadius;

  /// Elevation (shadow) of the menu.
  final double elevation;

  /// Duration of the menu appearance animation.
  final Duration animationDuration;

  /// Creates a context menu configuration with customizable styling.
  const ContextMenuConfig({
    this.backgroundColor = Colors.white,
    this.hoverColor = const Color(0xFFE0E0E0),
    this.textStyle = const TextStyle(fontSize: 14),
    this.itemHeight = 40.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });
}
