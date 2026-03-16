# flutter_root_context_menu

A customizable context menu package for Flutter with animation support, flexible styling, and web-like behavior.

## Features

- Manual trigger with full control over position and timing
- 8 built-in animations + custom animation support
- Custom widget items (Switch, Checkbox, Slider, etc.)
- Customizable styling (colors, sizes, elevation, shadows, border radius)
- Smart positioning with automatic overflow prevention
- Area constraints via `ContextMenuArea`
- Auto-close on route changes via `ContextMenuRouteObserver`
- Async callback support

## Installation

```yaml
dependencies:
  flutter_root_context_menu: ^0.6.0
```

## Quick Start

```dart
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

GestureDetector(
  onSecondaryTapDown: (details) {
    showRootContextMenu(
      context: context,
      position: details.globalPosition,
      items: [
        ContextMenuItem(
          label: 'Copy',
          icon: Icon(Icons.copy, size: 18),
          onTap: () => print('Copy'),
        ),
        ContextMenuItem.divider(),
        ContextMenuItem(
          label: 'Delete',
          icon: Icon(Icons.delete, size: 18),
          textColor: Colors.red,
          onTap: () => print('Delete'),
        ),
      ],
    );
  },
  child: Text('Right-click me'),
)
```

## Menu Item Types

| Type | Description |
|------|-------------|
| `ContextMenuItem(...)` | Standard item with label, icon, onTap |
| `ContextMenuItem.divider()` | Separator line |
| `ContextMenuItem.custom(builder: ...)` | Custom widget (Switch, Checkbox, etc.) |

## Configuration Options

```dart
ContextMenuConfig(
  backgroundColor: Colors.white,
  hoverColor: Color(0xFFE0E0E0),
  textStyle: TextStyle(fontSize: 14),
  itemHeight: 40.0,
  minWidth: 180.0,
  maxWidth: 280.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 16.0),
  borderRadius: BorderRadius.circular(8.0),
  elevation: 8.0,
  animationDuration: Duration(milliseconds: 200),
  animationBuilder: ContextMenuAnimations.popup,
  screenPadding: EdgeInsets.zero,
  itemBorderRadius: BorderRadius.zero,
  itemMargin: EdgeInsets.zero,
  dividerMargin: EdgeInsets.zero,
  menuPadding: EdgeInsets.zero,
  iconWidth: 0,
  iconSpacing: 0,
  boxShadow: null,
)
```

## Available Animations

| Animation | Description |
|-----------|-------------|
| `popup` | Scale + fade (default) |
| `fade` | Fade in only |
| `slideUp` | Slide from bottom |
| `slideDown` | Slide from top |
| `slideRight` | Slide from left |
| `bounce` | Elastic bounce effect |
| `scale` | Scale only |
| `none` | No animation |

## Helper Functions

```dart
closeRootContextMenu();       // Close the menu
isRootContextMenuOpen();      // Check if menu is open
```

## Documentation

- [Basic Usage & Styling](doc/basic-usage.md)
- [Custom Widget Items](doc/custom-widget-items.md)
- [Area Constraints](doc/area-constraints.md)
- [Animations](doc/animations.md)
- [Route Observer & Manual Control](doc/route-observer.md)

## Example App

```bash
cd example
flutter run
```

## License

MIT License
