# Appearance

## What it is
How a panel looks: colours, sizes, padding, radius, shadow, the optional title and the disabled style, all set through `ContextMenuConfig`. The panel body is built in `_ContextMenuPanel._buildMenuContent`.

## Governing decisions
**None** as records. CHANGELOG 0.10.0 (commit 5ee805f) states the policy this area keeps: "the library styles only what it renders (text, default chevron); user-provided widgets are rendered unchanged."

## Design model
Confirmed against the source:
- **Style only what we render.** Item icons and a custom `SubmenuConfig.icon` are drawn as given, enabled or not. Disabled items change only their text: `disabledTextStyle` as is when set (ignoring `textColor`), else `textStyle.copyWith(color: Colors.grey)` (`_ContextMenuItemWidgetState.build`).
- `boxShadow`, when set, replaces `elevation`: the panel is a decorated `Container` around a zero-elevation `Material`.
- The title shows only on the root panel (`title: i == 0 ? widget.title : null`), followed by a 1px divider.
- The body is an `IntrinsicWidth` column between `minWidth` and `maxWidth`. `iconWidth > 0` fixes the icon slot width and enables `iconSpacing`.
- Every default lives in the `ContextMenuConfig` constructor; the README "Configuration Options" table repeats them.

## Code
- `lib/src/models/context_menu_config.dart — ContextMenuConfig`
- `lib/src/widgets/context_menu_overlay.dart — _ContextMenuPanel._buildMenuContent`
- `lib/src/widgets/context_menu_item_widget.dart — _ContextMenuItemWidgetState.build` (text style, icon slot, hover colour, chevron)

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [Positioning](positioning.md): any size-affecting field changes the measured panel size and so where it is clamped.
- [Menu items](menu-items.md): item rendering reads most of these fields.
- [Package release](package-release.md): a new field or changed default is public API; README's options table and `doc/basic-usage.md` repeat the defaults.
- [Example playground](example-playground.md): `PlaygroundSettings` mirrors these fields for the control panel.

## Known holes / open
- `SubmenuConfig.icon`'s doc comment still says the default chevron is wrapped in `Opacity` (0.6 enabled, 0.3 disabled). The code draws `const Icon(Icons.chevron_right, size: 16)` with no `Opacity`, as CHANGELOG 0.10.0 says.
- No theming: defaults are fixed light colours and do not read `Theme.of(context)`.
