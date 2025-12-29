import 'dart:ui';

/// Utility class for calculating menu position with overflow handling.
class MenuPositionCalculator {
  /// Calculates the optimal position for the context menu.
  ///
  /// Takes into account the [position] where the menu should appear,
  /// the [menuSize], and optional [areaConstraints] to ensure the menu
  /// stays within bounds.
  ///
  /// If the menu would overflow the area boundaries, it automatically
  /// adjusts the position to keep the entire menu visible.
  static Offset calculate({
    required Offset position,
    required Size menuSize,
    required Size screenSize,
    Rect? areaConstraints,
  }) {
    // Use area constraints if provided, otherwise use full screen
    final effectiveArea = areaConstraints ??
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    double left = position.dx;
    double top = position.dy;

    // Check right overflow
    if (left + menuSize.width > effectiveArea.right) {
      left = effectiveArea.right - menuSize.width;
    }

    // Check bottom overflow
    if (top + menuSize.height > effectiveArea.bottom) {
      top = effectiveArea.bottom - menuSize.height;
    }

    // Check left boundary
    if (left < effectiveArea.left) {
      left = effectiveArea.left;
    }

    // Check top boundary
    if (top < effectiveArea.top) {
      top = effectiveArea.top;
    }

    return Offset(left, top);
  }
}
