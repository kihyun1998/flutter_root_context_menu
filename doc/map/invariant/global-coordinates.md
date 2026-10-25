# Global coordinates

## The fact
Every menu position and bound is in global (screen) coordinates, and the final position is used directly as a `Positioned` offset inside the overlay the menu was inserted into. This is only correct when that overlay's origin is the screen origin.

## Why it is cross-cutting
Four sites each produce or consume a coordinate on the assumption that global equals overlay-local, and none converts through a shared helper:
- the caller passes `details.globalPosition` as `position` (README, doc/basic-usage.md, `showRootContextMenu`'s doc example);
- `_ContextMenuAreaProvider.getAreaBounds` builds the area rect with `localToGlobal`;
- `_ContextMenuRootState._handlePanelMeasured` builds parent and trigger bounds with `localToGlobal` and uses `MediaQuery.size` from origin (0,0) as the default area;
- `_ContextMenuPanel.build` places `Positioned(left: position.dx, top: position.dy)` inside the overlay's `Stack`.
Converting one site to overlay-local coordinates without the others would misplace menus even in the common case. Kept as an invariant and as a known defect (maintainer, 2026-10-25).

## Territories it holds in
- [Positioning](../territory/positioning.md): `_handlePanelMeasured`, `_ContextMenuPanel.build`.
- [Area constraints](../territory/area-constraints.md): `getAreaBounds`.
- [Submenu tree](../territory/submenu-tree.md): parent and trigger bounds for each new level.
- [Menu lifecycle](../territory/menu-lifecycle.md): `showMenu` inserts into `Overlay.of(context)`, the nearest overlay, which decides whose origin matters.

## What a violation looks like
The menu appears offset from the click by the overlay's top-left. Reproduces when the nearest `Overlay` is not at the screen origin, for example a nested `Navigator` inside a side panel, or a `MaterialApp` embedded below other content.

## Discovery history
- Found by reading during the first map build (grill-map init, 2026-10-25): `showMenu` uses `Overlay.of(context)` while every position is global. `ContextMenuOutsideLayer._forwardToWidgetsBelow` is the one place that converts explicitly (`getTransformTo(null)`).

## Where it will recur
Any code that computes a rect or offset for something drawn inside the menu's overlay is subject to this: if it calls `localToGlobal` or reads a global pointer position, check that it lands in the same space as `_ContextMenuPanel`'s `Positioned`.
