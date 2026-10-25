# Submenu tree

## What it is
Nested submenus: the stack of open panels (root at depth 0, submenus above it), the hover timers that open and close them, and the depth limit. Configured through `SubmenuConfig`.

## Governing decisions
`plan.md` (the submenu implementation plan, internal and pubignored) is the design this area was built from; sections 3, 5 and 9 describe the timer rules below. Where code and plan differ, see `## Known holes / open`.

## Design model
Confirmed against `context_menu_overlay.dart`:
- One `_MenuLevel` per open panel in `_menuStack`; opening at depth N+1 first closes everything at N+1 and above (`_openSubmenu` → `_closeSubmenusFrom`).
- One global open timer (`_openTimer`); a new hover cancels the previous one. Close timers are one per depth (`_closeTimers`, set through `_setCloseTimer`, which cancels the old timer first).
- Entering a panel at depth N cancels the close timers of depths 1..N, so moving from depth 1 into depth 2 does not let depth 1's exit timer close everything (`_handlePanelEnter`).
- The root panel (depth 0) never schedules its own close.
- Hovering a non-submenu item closes deeper panels immediately and cancels the open timer. Dividers and custom items get no hover callback, so hovering them changes nothing.
- Every timer callback checks `mounted`; `dispose` cancels all timers.
- Depth limit: `_openSubmenu` returns when `parentDepth + 1 >= submenu.maxDepth`. With the default `maxDepth: 5`, panels at depths 0..4 can exist.
- Defaults: `openDelay` 200 ms, `closeDelay` 300 ms, `horizontalOffset` -4 (`submenu_config.dart — SubmenuConfig`). The close delay covers the gap the pointer crosses from parent item to submenu panel (`plan.md` §5).

## Code
- `lib/src/widgets/context_menu_overlay.dart — _MenuLevel, _ContextMenuRootState._openSubmenu, _closeSubmenusFrom, _handleSubmenuItemHover, _handleSubmenuItemUnhover, _handleNonSubmenuItemHover, _handlePanelEnter, _handlePanelExit, _getActiveChildIndex, _setCloseTimer, _cancelCloseTimer, _cancelOpenTimer`
- `lib/src/models/submenu_config.dart — SubmenuConfig, copyWith, operator ==`
- `lib/src/widgets/context_menu_item_widget.dart — _ContextMenuItemWidgetState.build` (onEnter / onExit / tap for submenu items)

## Reference behaviour
**None.**

## Cross-cutting invariants
- [Global coordinates](../invariant/global-coordinates.md): a submenu's position is computed from its parent's and trigger item's global bounds.

## Blast radius
- [Positioning](positioning.md): every new level is measured after its first frame and placed from the parent panel's bounds; the `menuKey` check in `_schedulePostFrameMeasurement` is what stops a closed level's measurement landing on a newer one.
- [Animations](animations.md): `openedLeft`, set at measurement, picks slideLeft or slideRight for the submenu.
- [Menu items](menu-items.md): which hover callback an item receives depends on its kind.
- [Menu lifecycle](menu-lifecycle.md): timers are only fully cancelled when the entry is disposed.
- [Example playground](example-playground.md): the Submenu section drives every `SubmenuConfig` field.

## Known holes / open
- **Bug:** tapping a submenu item waits `openDelay` before opening. `plan.md` §5 and §9 #8 say a tap opens immediately for touch devices; the code routes the tap through `_handleSubmenuItemHover`, which starts the timer. The intended behaviour is immediate (maintainer, 2026-10-25).
- **Open question:** at the depth limit, a submenu item still shows its chevron and highlights but never opens. README says "unlimited depth" (Features) and "Unlimited nesting depth (configurable via `SubmenuConfig.maxDepth`)". Whether the limit should be visible to the user is undecided (maintainer, 2026-10-25).
- `SubmenuConfig.operator ==` and `hashCode` leave out `icon`.
- No test covers submenus: `grep -n -i submenu test/*.dart` prints nothing.
- RTL locales: submenus always try the right side first (`plan.md` §10).
- No keyboard navigation (`plan.md` §10).
