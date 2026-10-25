# Territory map

<!-- grill-map build stamp: 18c00d1 -->
<!-- grill-map synced at: 5905e4f (2026-10-25) -->

The territory map of `flutter_root_context_menu`. A comment's why, trap and measured value go to a note here.

## The two questions

- **If I touch this, what else moves?** Open the territory that owns the code, then walk its `## Blast radius` and `## Cross-cutting invariants`.
- **What decision is this shape derived from?** Read the note's `## Governing decisions`. A **None.** there is itself the answer: nothing recorded governs it.

`## Blast radius` is a checklist: an edge with nothing to do for your change is a correct outcome.

## Territories

- [Menu lifecycle](territory/menu-lifecycle.md)
- [Menu items](territory/menu-items.md)
- [Submenu tree](territory/submenu-tree.md)
- [Positioning](territory/positioning.md)
- [Area constraints](territory/area-constraints.md)
- [Appearance](territory/appearance.md)
- [Animations](territory/animations.md)
- [Outside input](territory/outside-input.md)
- [Package release](territory/package-release.md)
- [Example playground](territory/example-playground.md)

## Cross-cutting invariants

- [Global coordinates](invariant/global-coordinates.md)

## Conventions

- Section headings are the same exact strings in every note; an empty section says **None.**
- Code is cited by symbol (`file — Type.method`), never by line number.
- Facts another file owns are linked, not copied; an issue is cited as evidence, not as a status.
- Every claim carries its evidence (a symbol, a commit, an issue) or its source and date, e.g. `(maintainer, 2026-10-25)`.

## What the map cannot answer

Source files and issues are text inside notes, not nodes; the map does not list every caller of a symbol. Use `git grep` for that.

## Scope

The published package (`lib/`, `test/`, `example/`, `doc/` guides, manifest and changelog). Out of scope: `plan.md` and `todo.md` (internal notes; `todo.md`'s one item, nested menus, shipped in 0.7.0), and the agent tooling in `doc/agents/`, `docs/agents/` and this folder.

A territory appears when something in the repo commits to it: code, a design in an open issue, or a plan. An absent note means nothing does. RTL support, keyboard navigation and exit animations have no note: they are only open lines in the notes they would touch.

## Shape of the repo

A small single-package library (about 1,800 lines under `lib/`). One file, `lib/src/widgets/context_menu_overlay.dart`, holds the submenu tree, positioning orchestration, animation driving and panel rendering, so it appears in five territories. There are no decision records; the design history lives in `plan.md`, CHANGELOG and issues #2 and #4. The largest gap is testing: the only tests cover the helpers and the barrier, and nothing covers submenus, positioning or animations. Tracked: #13
