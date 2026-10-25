# Example playground

## What it is
The example app shipped under `example/`: a playground page whose control panel edits every option and a demo menu that uses every item kind, plus a second page that shows auto-close on navigation.

## Governing decisions
**None.**

## Design model
From reading the source and CHANGELOG:
- Each feature release adds a matching control-panel section (CHANGELOG `example` lines for 0.7.0, 0.9.0, 0.10.0, 0.11.0).
- `PlaygroundSettings` holds the state the control panel edits; `PlaygroundContent` builds the `ContextMenuConfig` and opens the menu from inside a `ContextMenuArea`.
- `MyApp` registers `ContextMenuRouteObserver`; `SecondPage` demonstrates it.
- Depends on the package by `path: ../` (`example/pubspec.yaml`).

## Code
- `example/lib/main.dart — MyApp`
- `example/lib/models/playground_settings.dart — PlaygroundSettings`
- `example/lib/pages/playground_page.dart — PlaygroundPage`
- `example/lib/pages/second_page.dart — SecondPage`
- `example/lib/widgets/control_panel.dart — ControlPanel` (one `_build…Section` per feature: `grep -n '_build.*Section()' example/lib/widgets/control_panel.dart`)
- `example/lib/widgets/playground_content.dart — PlaygroundContent`

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [Package release](package-release.md): `example/` is published with the package and is what pub.dev shows as the example.

## Known holes / open
- `example/test/widget_test.dart` exists; whether it still matches the app was not checked.
