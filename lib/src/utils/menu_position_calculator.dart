import 'package:flutter/material.dart';

/// Utility class for calculating menu position with overflow handling.
class MenuPositionCalculator {
  /// Calculates the optimal position for the context menu.
  ///
  /// Takes into account the [position] where the menu should appear,
  /// the [menuSize], and optional [areaConstraints] to ensure the menu
  /// stays within bounds.
  ///
  /// The [padding] parameter allows specifying minimum distance from
  /// screen edges. For example, `EdgeInsets.only(bottom: 10)` will ensure
  /// the menu stays at least 10px away from the bottom edge.
  ///
  /// If the menu would overflow the area boundaries, it automatically
  /// adjusts the position to keep the entire menu visible.
  static Offset calculate({
    required Offset position,
    required Size menuSize,
    required Size screenSize,
    Rect? areaConstraints,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    // Use area constraints if provided, otherwise use full screen
    final effectiveArea = areaConstraints ??
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    double left = position.dx;
    double top = position.dy;

    // Check right overflow (with padding)
    if (left + menuSize.width > effectiveArea.right - padding.right) {
      left = effectiveArea.right - menuSize.width - padding.right;
    }

    // Check bottom overflow (with padding)
    if (top + menuSize.height > effectiveArea.bottom - padding.bottom) {
      top = effectiveArea.bottom - menuSize.height - padding.bottom;
    }

    // Check left boundary (with padding)
    if (left < effectiveArea.left + padding.left) {
      left = effectiveArea.left + padding.left;
    }

    // Check top boundary (with padding)
    if (top < effectiveArea.top + padding.top) {
      top = effectiveArea.top + padding.top;
    }

    return Offset(left, top);
  }
}
