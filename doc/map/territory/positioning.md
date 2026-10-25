# Positioning

## What it is
Where each panel appears. The root panel is placed at the caller's position and moved back inside the allowed area when it would overflow. A submenu is placed beside its parent panel, flipping to the left when the right side has no room. Placement uses each panel's real rendered size, measured after its first frame.

## Governing decisions
**None** as records. CHANGELOG 0.6.1 records the move from a pre-calculated size to post-frame measurement ("accurate menu positioning with custom widget items"). The submenu flip follows `plan.md` §6.

## Design model
Confirmed against the source:
- **Measure, then place.** A new level starts unmeasured and is painted at `Opacity` 0. A post-frame callback reads the panel's `RenderBox` size through its `menuKey`, computes the position and sets `measured = true`, which makes it visible and starts its animation (`_schedulePostFrameMeasurement`, `_handlePanelMeasured`, `_ContextMenuPanel.build`).
- A stale callback is dropped when the level at that depth now has a different `menuKey`, the depth no longer exists, or the state is unmounted.
- **Root:** `MenuPositionCalculator.calculate` clamps right, then bottom, then left, then top. Left and top win when the menu is larger than the area.
- **Submenu:** `calculateSubmenu` starts at `parent.right + horizontalOffset`, aligned with the trigger item's top; on right overflow it flips to `parent.left - width - horizontalOffset`; then clamps left, bottom and top. `openedLeft` is recorded as `newPos.dx < parentBounds.left`.
- The allowed area is the [area constraints](area-constraints.md) rect when present, else `Rect(0, 0, MediaQuery.size)`, shrunk by `config.screenPadding`.
- Inputs from outside: the caller's `position` and the panel's measured size; nothing bounds either, and clamping handles any value.

## Code
- `lib/src/utils/menu_position_calculator.dart — MenuPositionCalculator.calculate, calculateSubmenu`
- `lib/src/widgets/context_menu_overlay.dart — _ContextMenuRootState._schedulePostFrameMeasurement, _handlePanelMeasured; _ContextMenuPanel.build`
- `lib/src/models/context_menu_config.dart — ContextMenuConfig.screenPadding`
- `lib/src/models/submenu_config.dart — SubmenuConfig.horizontalOffset`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [Global coordinates](../invariant/global-coordinates.md): every rect and offset here is global, and the result is used as an overlay-local `Positioned` offset.

## Blast radius
- [Animations](animations.md): the animation starts only when `measured` flips to true, and `openedLeft` chooses the submenu slide direction; changing when measurement completes changes both.
- [Area constraints](area-constraints.md): the bounds it returns are the clamp area; a rect in another coordinate space shifts every clamp.
- [Submenu tree](submenu-tree.md): a submenu needs its parent's and trigger item's render boxes at measurement time; closing either first silently skips placement (`_handlePanelMeasured` returns early).
- [Appearance](appearance.md): `minWidth`, `maxWidth`, `itemHeight`, padding and title change the measured size.

## Known holes / open
- When the overlay does not start at the screen origin, panels land offset by the overlay's origin. See [global coordinates](../invariant/global-coordinates.md). Tracked: #12
- If the parent or trigger render box is gone at measurement, the submenu stays at `Offset.zero` with opacity 0 until it closes; it is invisible but its `MouseRegion` still sits at the top-left.
- No re-measurement after the first frame: a panel whose content later changes size (a custom item) keeps its first position.
- No re-placement on window resize (`plan.md` §10).
