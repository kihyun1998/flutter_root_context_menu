## 0.3.1

- **feat**: Add `builder` parameter to `ContextMenuArea` for correct context handling
- **feat**: Add `iconWidth` and `iconSpacing` config options for precise icon sizing
- **fix**: Menu width calculation now uses actual content width instead of always using maxWidth
- **docs**: Add `ContextMenuArea` and disabled items documentation to README

## 0.3.0

- **feat**: Add `itemBorderRadius` for rounded corners on menu item hover backgrounds
- **feat**: Add `itemMargin` for spacing around individual menu items
- **feat**: Add `dividerMargin` for vertical spacing around dividers
- **feat**: Add `menuPadding` for padding inside menu container
- **feat**: Add playground controls for all new styling options
- **fix**: Improve menu size calculation to include all margins and paddings

## 0.2.0

- **feat**: Add `screenPadding` parameter to control minimum distance from screen edges
- **feat**: Add playground controls for adjusting screen padding in real-time

## 0.1.0

Initial release with core features:

- Manual trigger context menu with `showContextMenu()`
- Flexible icon support (Material Icons, SVG, custom widgets)
- 8 built-in animations + custom animation support
- Customizable styling (colors, sizes, elevation, border radius)
- Adjustable menu width (minWidth, maxWidth)
- Web-like click behavior (single click closes menu and triggers action)
- Automatic overflow prevention
- Interactive example playground
