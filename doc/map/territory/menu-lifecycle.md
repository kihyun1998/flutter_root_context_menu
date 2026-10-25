# Menu lifecycle

## What it is
Opening and closing the one root context menu. A process-wide singleton controller holds at most one `OverlayEntry`; showing a menu always removes the previous one first, and every close path ends in the same `hideMenu`. The three public helpers and the route observer are thin callers of that controller.

## Governing decisions
**None.** No decision records exist. [#2](https://github.com/kihyun1998/flutter_root_context_menu/issues/2)'s implementation decisions ("no new overlay entry", "single source of lifecycle") constrain this area from the barrier side; they are recorded under [outside-input](outside-input.md).

## Design model
From reading the source:
- At most one menu exists at a time: `RootContextMenuController.showMenu` calls `hideMenu` before inserting (`context_menu_controller.dart — showMenu`).
- "Open" means exactly "the controller holds an entry": `isMenuOpen => _currentMenuEntry != null`. Everything drawn for a menu (panels, outside layer, barrier) lives inside that one entry, so removing it removes all of them.
- Close paths, all calling `RootContextMenuController().hideMenu()`: an outside pointer-down (`ContextMenuRoot.build` → `ContextMenuOutsideLayer.onPointerDown`), a tap on an enabled non-submenu item (`_ContextMenuItemWidgetState.build`), `closeRootContextMenu`, any navigator push/pop/remove/replace when `ContextMenuRouteObserver` is registered, and a new `showMenu`. Command for the tool-visible half: `git grep -n 'hideMenu()' -- lib`.
- The entry goes into `Overlay.of(context)`, the nearest overlay to the caller's context, not the root overlay.
- `ContextMenuRoot`'s state (submenu stack, timers) dies with the entry; `dispose` cancels every timer.

## Code
- `lib/src/controller/context_menu_controller.dart — RootContextMenuController.showMenu, hideMenu, isMenuOpen`
- `lib/src/context_menu_helpers.dart — showRootContextMenu, closeRootContextMenu, isRootContextMenuOpen`
- `lib/src/controller/context_menu_route_observer.dart — ContextMenuRouteObserver.didPush, didPop, didRemove, didReplace`
- `lib/src/widgets/context_menu_overlay.dart — ContextMenuRoot, _ContextMenuRootState.dispose`
- `test/flutter_root_context_menu_test.dart — group 'Context Menu Helper Functions'`

## Reference behaviour
**None.** Never compared against Flutter's `MenuAnchor` / `PopupMenuButton` lifecycle (see `docs/agents/thegraph.md` for that reference).

## Cross-cutting invariants
- [Global coordinates](../invariant/global-coordinates.md): the entry goes into the nearest overlay, and positions are placed as if that overlay started at the screen origin.

## Blast radius
- [Outside input](outside-input.md): the barrier relies on living inside this one entry so that every close path also removes it; a second entry or a close path that skips `hideMenu` leaves an invisible blocking layer.
- [Submenu tree](submenu-tree.md): its timers are owned by `ContextMenuRoot` and only cancelled by `dispose`; a lifecycle that kept the state alive across menus would leak timers that fire into a stale stack.
- [Menu items](menu-items.md): an item tap closes the menu before running `onTap` in a microtask; changing the close order changes what the callback sees (`isRootContextMenuOpen` is already false inside it).
- [Package release](package-release.md): the helpers and controller are public API; a signature change is a breaking release.

## Known holes / open
- Two menus cannot coexist (one per process), including across separate overlays or windows. Unclear whether that is intended for multi-`Navigator` apps.
- Plan's known limitations (`plan.md` §10): a window resize or rotation while open leaves the menu where it was; nothing listens to `didChangeMetrics`.
- No keyboard dismissal (Escape) exists (`plan.md` §10).
