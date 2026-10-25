# Package release

## What it is
Shipping the package to pub.dev: the manifest, what is published and what is kept out, the changelog, the user guides in `doc/` and README, and dependency upkeep.

## Governing decisions
**None** as records. [#6](https://github.com/kihyun1998/flutter_root_context_menu/issues/6) holds the design for Dependabot (root pub monthly with `increase-if-necessary`, no `github-actions` entry since there is no workflow; `example/` dependency PRs grouped, since nothing is published from `example/`).

## Design model
From reading the repo:
- `pubspec.yaml` is the source of version, description, SDK floors and dependencies; README's install snippet repeats the version.
- `.pubignore` keeps internal files out of the published archive: `plan.md`, `todo.md`, `doc/agents/`, `doc/map/` (commit c7cddbc and later). Everything else under `doc/` ships as user guides.
- Each release adds a CHANGELOG section with `feat` / `fix` / `BREAKING` / `example` lines; BREAKING changes bump the minor version while at `0.x` (0.8.0, 0.10.0).
- The only non-SDK dependency is the dev dependency `flutter_lints`.
- There is no CI: no `.github/` directory.

## Code
- `pubspec.yaml`, `.pubignore`, `CHANGELOG.md`, `README.md`, `doc/*.md`, `analysis_options.yaml`, `LICENSE`
- `lib/flutter_root_context_menu.dart` — the exported surface

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [Example playground](example-playground.md): ships in the package as `example/` and depends on the package by `path: ../`.

## Known holes / open
- Dependabot is designed but not configured. Tracked: #6.
- README says "Nested submenu support with unlimited depth" while `SubmenuConfig.maxDepth` defaults to 5 (see [submenu tree](submenu-tree.md)). Tracked: #8
- No CI runs `flutter analyze` or the tests.
