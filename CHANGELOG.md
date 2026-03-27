## 0.7.0

- **feat**: Add `ContextMenuItem.submenu()` for nested submenu support with unlimited depth
- **feat**: Submenus open on hover (desktop) and tap (touch) with configurable delays
- **feat**: Smart submenu positioning with automatic left/right flip on screen edge overflow
- **feat**: Add `submenuOpenDelay`, `submenuCloseDelay`, `submenuHorizontalOffset` config options
- **feat**: Add `submenuAnimationBuilder` and `submenuAnimationDuration` for independent submenu animation control
- **feat**: Add `maxSubmenuDepth` config to limit nesting depth
- **feat**: Add `ContextMenuAnimations.slideLeft` animation for left-opening submenus
- **feat**: Auto-select slideRight/slideLeft animation based on submenu open direction
- **refactor**: Restructure overlay into `ContextMenuRoot` + `_ContextMenuPanel` architecture
- **example**: Add submenu playground controls (animation, delays, offset, max depth)
- **example**: Add Share (2-level nested) and Export As submenu demo items

## 0.6.1

- **fix**: Use post-frame measurement for accurate menu positioning with custom widget items
- **refactor**: Replace pre-calculated menu size with actual rendered size measurement via `GlobalKey`
- **example**: Add volume slider and theme color palette custom menu items

## 0.6.0

- **feat**: Add `ContextMenuItem.custom()` for rendering custom widgets inside menu items
- **feat**: Custom items support interactive widgets like `Switch`, `Checkbox`, `Slider` without auto-closing the menu
- **feat**: Add `customHeight` parameter for custom items to override default item height
- **refactor**: Restructure example app with separation of concerns (models, pages, widgets folders)

## 0.5.1

- **feat**: Add `closeRootContextMenu()` helper function for explicitly closing menus
- **feat**: Add `isRootContextMenuOpen()` helper function to check if a menu is currently open
- **docs**: Add manual control examples to README with new helper functions

## 0.5.0

- **fix**: Allow click events to pass through to underlying widgets when menu is open - clicking outside the menu now closes it AND triggers the clicked widget in a single action

## 0.4.3

- **fix**: Support async callbacks in onTap to prevent UI blocking when menu items execute asynchronous operations
- **fix**: Execute onTap callbacks in microtask to avoid blocking the event loop during heavy synchronous operations
- **fix**: Improve menu closing behavior - clicking outside the menu now closes it immediately without delay

## 0.4.2

- **fix**: Fix menu item onTap callback and prevent new menu from being immediately closed

## 0.4.1

- **fix**: Fix menu item onTap callback not being triggered due to pointer event handling

## 0.4.0

- **BREAKING**: Rename `showContextMenu` to `showRootContextMenu` to avoid naming conflicts
- **feat**: Add `boxShadow` parameter to `ContextMenuConfig` for custom shadow styling
- **feat**: Add playground controls for customizing box shadow (blur, spread, offset, opacity, color)
- **fix**: Ensure Material widget is present when using custom boxShadow to prevent InkWell errors

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

- Manual trigger context menu with `showRootContextMenu()`
- Flexible icon support (Material Icons, SVG, custom widgets)
- 8 built-in animations + custom animation support
- Customizable styling (colors, sizes, elevation, border radius)
- Adjustable menu width (minWidth, maxWidth)
- Web-like click behavior (single click closes menu and triggers action)
- Automatic overflow prevention
- Interactive example playground
