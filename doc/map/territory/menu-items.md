# Menu items

## What it is
The item model a caller passes in and how each kind renders and reacts. One class, `ContextMenuItem`, carries four kinds selected by constructor: standard (label, icon, `onTap`), divider, custom (caller-built widget), and submenu (children).

## Governing decisions
**None** as records. The CHANGELOG 0.10.0 entry states the rendering policy: "the library styles only what it renders (text, default chevron); user-provided widgets are rendered unchanged." That policy is owned by [appearance](appearance.md).

## Design model
From reading the source:
- Kind flags are exclusive by construction: each named constructor fixes `isDivider`, `isCustom` and `children` (`context_menu_item.dart`). `isSubmenu` is derived: `children != null && children!.isNotEmpty`.
- Standard item tap, when enabled: `hideMenu()` first, then `onTap` via `Future.microtask`, so a slow or async callback does not block closing (CHANGELOG 0.4.3). `onTap` is typed `Function?` and called with no arguments.
- Custom items render `builder` inside a `StatefulBuilder` at `customHeight ?? config.itemHeight`, get no hover or tap handling from the library, and never close the menu (CHANGELOG 0.6.0).
- Dividers render a 1px `Divider` padded by `config.dividerMargin`; they are created `enabled: false`.
- Submenu items show the chevron, take hover and tap from the [submenu tree](submenu-tree.md), and never run `onTap` (the constructor sets it to null).
- Cursor: `SystemMouseCursors.click` when enabled, `forbidden` when disabled (CHANGELOG 0.10.1, commit 3094285).
- Hover highlight shows when hovered or when this item is the parent of the open submenu, and only when enabled.

## Code
- `lib/src/models/context_menu_item.dart — ContextMenuItem, .divider, .custom, .submenu, isSubmenu`
- `lib/src/widgets/context_menu_item_widget.dart — ContextMenuItemWidget, _ContextMenuItemWidgetState.build`
- `lib/src/widgets/context_menu_overlay.dart — _ContextMenuPanel._buildMenuContent` (wires the hover callbacks per kind)

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [Submenu tree](submenu-tree.md): the panel decides which hover callback an item gets from its kind (`isSubmenu`, `isDivider`, `isCustom`); a new kind or changed flag silently changes which submenus close on hover.
- [Positioning](positioning.md): an item's rendered height feeds the measured panel size; a custom item's height comes from the caller.
- [Appearance](appearance.md): item text style, disabled style and the chevron follow the "style only what we render" policy.
- [Menu lifecycle](menu-lifecycle.md): tap closes through `hideMenu` before the callback.
- [Example playground](example-playground.md): the demo menu exercises every kind.

## Known holes / open
- `ContextMenuItem.submenu` with an empty `children` list renders as a plain item with no `onTap` that still closes the menu on tap. `plan.md` §9 #16 planned an assert; none exists (`git grep -n assert -- lib/src/models/context_menu_item.dart` prints nothing). Tracked: #10
- Errors thrown by an async `onTap` are not caught by the library.
