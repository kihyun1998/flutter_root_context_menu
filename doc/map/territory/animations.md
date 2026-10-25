# Animations

## What it is
How a panel appears. An animation is any `ContextMenuAnimationBuilder (progress, child)`; `ContextMenuAnimations` ships nine of them, and the panel drives one with a `TweenAnimationBuilder` from 0 to 1.

## Governing decisions
**None.**

## Design model
Confirmed against `context_menu_overlay.dart — _ContextMenuPanel`:
- The animation runs only once the panel is measured: before that the tween is fixed at 1 with zero duration and the panel is at opacity 0; on `measured` the `ValueKey('animated')` remounts the tween from 0.
- Builder choice: root uses `config.animationBuilder ?? popup`; a submenu uses `submenu.animationBuilder` when set, else `slideLeft` when it opened left and `slideRight` otherwise.
- Duration: submenus use `submenu.animationDuration ?? config.animationDuration`.
- The built-ins: `git grep -n 'static Widget' -- lib/src/models/context_menu_animation.dart`.

## Code
- `lib/src/models/context_menu_animation.dart — ContextMenuAnimationBuilder, ContextMenuAnimations`
- `lib/src/widgets/context_menu_overlay.dart — _ContextMenuPanel._resolveAnimationBuilder, _ContextMenuPanel.build`

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [Positioning](positioning.md): the start of the animation is the moment measurement completes; scale animations anchor at `Alignment.topLeft`, which assumes the clamped top-left is the menu's origin.
- [Submenu tree](submenu-tree.md): `openedLeft` comes from submenu placement.
- [Package release](package-release.md): the set of built-ins is listed in README ("Available Animations") and `doc/animations.md`.

## Known holes / open
- No exit animation: `hideMenu` removes the entry at once.
