# Outside input

## What it is
What happens to pointer input outside the menu panels while a menu is open. A full-screen layer under the panels closes the menu on any pointer-down. By default all input passes through to the app below; with `useBarrier` the layer absorbs it; with `barrierPassesSecondaryClick` as well, a right-click is forwarded to the widgets below so one right-click can close this menu and open the next.

## Governing decisions
- [#2](https://github.com/kihyun1998/flutter_root_context_menu/issues/2), implementation decisions: no second `OverlayEntry`, the barrier lives in the existing outside layer; the dismissing click is consumed; the barrier is invisible; off by default. Built in #3 (commit c5cb742).
- [#4](https://github.com/kihyun1998/flutter_root_context_menu/issues/4), implementation decisions: forward the real pointer-down, never a synthesized one, before the gesture arena for that pointer closes; only meaningful with the barrier. Built in #5 (commit d03ee44).

## Design model
Confirmed against `context_menu_outside_layer.dart`:
- `RenderContextMenuOutsideLayer.hitTest` always adds itself (so it sees every pointer-down) and returns `blocking`: false lets the hit test continue to widgets below, true stops it there, which also blocks hover and scroll.
- `handleEvent` acts on `PointerDownEvent` only: it calls `onPointerDown` (which is `hideMenu`), then, when blocking and passing secondary clicks and the secondary button is down, forwards the event.
- Forwarding hit-tests the whole `Overlay` at the event's position with `_forwarding` set, so this layer reports no hit, and delivers the same event to each target with its transform. The overlay box is reached through `overlay.context.findRenderObject()` and its transform to the screen, so forwarding is correct in any overlay position.
- Only the down event is forwarded; later move/up events reach recognizers through the pointer router, not hit testing (#4).
- Forwarding stays within the menu's overlay: widgets above the overlay already received the event through the normal hit path and see it once (test 'on: widgets above the overlay see the right-click once').

## Code
- `lib/src/widgets/context_menu_outside_layer.dart — ContextMenuOutsideLayer, RenderContextMenuOutsideLayer.hitTest, handleEvent, _forwardToWidgetsBelow`
- `lib/src/widgets/context_menu_overlay.dart — _ContextMenuRootState.build` (the layer under the panels)
- `lib/src/context_menu_helpers.dart — showRootContextMenu` (`useBarrier`, `barrierPassesSecondaryClick`)
- `test/flutter_root_context_menu_test.dart — groups 'useBarrier', 'barrierPassesSecondaryClick'`

## Reference behaviour
**None.** #2 cites "Flutter's modal-barrier convention" for consuming the dismissing click, without a pinned source.

## Cross-cutting invariants
**None.** This layer converts coordinates explicitly and does not rely on [global coordinates](../invariant/global-coordinates.md).

## Blast radius
- [Menu lifecycle](menu-lifecycle.md): the barrier disappears only because it sits in the menu's entry; a close path that does not remove the entry leaves the app blocked.
- [Area constraints](area-constraints.md): a forwarded right-click reaches another area's `onSecondaryTapDown`, which opens a menu bounded by that area.
- [Example playground](example-playground.md): Barrier and "Pass right-click" toggles.

## Known holes / open
- Keyboard input is not blocked by the barrier (#4 out of scope).
- No "hover-only" blocking mode, and primary clicks never pass through (#2, #4 out of scope).
