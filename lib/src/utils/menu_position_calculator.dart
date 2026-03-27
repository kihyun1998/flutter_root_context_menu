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

  /// Calculates the optimal position for a submenu panel.
  ///
  /// Positions the submenu relative to the [parentPanelBounds] and the
  /// [triggerItemBounds] (the item that opened this submenu).
  ///
  /// By default, the submenu opens to the right of the parent menu,
  /// aligned with the trigger item's top edge. If there is not enough
  /// space on the right, it flips to the left side.
  ///
  /// Returns the calculated [Offset] for the submenu's top-left corner.
  static Offset calculateSubmenu({
    required Rect parentPanelBounds,
    required Rect triggerItemBounds,
    required Size submenuSize,
    required Size screenSize,
    Rect? areaConstraints,
    EdgeInsets padding = EdgeInsets.zero,
    double horizontalOffset = -4.0,
  }) {
    final effectiveArea = areaConstraints ??
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    // Default: right side of parent, aligned with trigger item top
    double left = parentPanelBounds.right + horizontalOffset;
    double top = triggerItemBounds.top;

    // Check right overflow → flip to left side
    if (left + submenuSize.width > effectiveArea.right - padding.right) {
      left = parentPanelBounds.left - submenuSize.width - horizontalOffset;
    }

    // Check left overflow → clamp to left edge
    if (left < effectiveArea.left + padding.left) {
      left = effectiveArea.left + padding.left;
    }

    // Check bottom overflow → shift up
    if (top + submenuSize.height > effectiveArea.bottom - padding.bottom) {
      top = effectiveArea.bottom - submenuSize.height - padding.bottom;
    }

    // Check top overflow → clamp to top edge
    if (top < effectiveArea.top + padding.top) {
      top = effectiveArea.top + padding.top;
    }

    return Offset(left, top);
  }
}
