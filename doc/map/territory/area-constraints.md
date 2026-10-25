# Area constraints

## What it is
`ContextMenuArea` lets a caller limit where menus opened beneath it may appear. It wraps its subtree, and `showRootContextMenu` looks up the nearest one and passes its global bounds to [positioning](positioning.md) as the clamp area.

## Governing decisions
**None.**

## Design model
From reading the source:
- `ContextMenuArea.of(context)` reads `_ContextMenuAreaProvider` with `dependOnInheritedWidgetOfExactType` and returns the keyed container's global rect (`localToGlobal(Offset.zero) & size`), or null when there is no ancestor or it has no size yet.
- The bounds are read once, when the menu opens; they are not tracked while it is open.
- The context passed to `showRootContextMenu` must be below the area. The `builder` form gives a context inside it; with `child`, the caller has to ensure it (doc/area-constraints.md).
- `child` and `builder` are mutually exclusive, enforced by asserts.

## Code
- `lib/src/widgets/context_menu_area.dart — ContextMenuArea, ContextMenuArea.of, _ContextMenuAreaState.build, _ContextMenuAreaProvider.getAreaBounds`
- `lib/src/context_menu_helpers.dart — showRootContextMenu` (the only caller of `ContextMenuArea.of`)

## Reference behaviour
**None.**

## Cross-cutting invariants
- [Global coordinates](../invariant/global-coordinates.md): the area rect is global.

## Blast radius
- [Positioning](positioning.md): the rect replaces the screen as the clamp area; a rect in another space or of another size moves every menu opened inside the area.
- [Outside input](outside-input.md): with `barrierPassesSecondaryClick`, a forwarded right-click lets another area open its menu in the same click (#4); that menu reads its own area's bounds.
- [Example playground](example-playground.md): both pages wrap their content in `ContextMenuArea`.

## Known holes / open
- The doc comment on `ContextMenuArea` names `[showContextMenu]`, which does not exist; the function is `showRootContextMenu`. Tracked: #9
- An area larger than the overlay, or partly off screen, is used as is; the menu can be clamped into a region that is not visible.
