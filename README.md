# flutter_root_context_menu

A customizable context menu package for Flutter with animation support, flexible styling, and web-like behavior.

## Features

- 🎯 **Manual Trigger** - Full control over when and where to show menus
- 🎨 **Flexible Icons** - Support for Material Icons, SVG, images, and custom widgets
- ✨ **8 Built-in Animations** - Fade, popup, slide, bounce, scale, and more
- 🎭 **Custom Animations** - Create your own animation effects
- 📐 **Customizable Styling** - Colors, sizes, elevation, border radius, and width
- 🖱️ **Web-like Behavior** - Single click closes menu and triggers action simultaneously
- 📍 **Smart Positioning** - Automatic overflow prevention
- 🎮 **Interactive Example** - Try the playground app to test all features

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_root_context_menu: ^0.1.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

ContextMenuArea(
  child: GestureDetector(
    onSecondaryTapDown: (details) {
      showContextMenu(
        context: context,
        position: details.globalPosition,
        items: [
          ContextMenuItem(
            label: 'Copy',
            icon: Icon(Icons.copy, size: 18),
            onTap: () => print('Copy clicked'),
          ),
          ContextMenuItem(
            label: 'Paste',
            icon: Icon(Icons.paste, size: 18),
            onTap: () => print('Paste clicked'),
          ),
          ContextMenuItem.divider(),
          ContextMenuItem(
            label: 'Delete',
            icon: Icon(Icons.delete, size: 18),
            textColor: Colors.red,
            onTap: () => print('Delete clicked'),
          ),
        ],
      );
    },
    child: Container(
      padding: EdgeInsets.all(20),
      child: Text('Right-click me'),
    ),
  ),
)
```

### With Custom Styling

```dart
showContextMenu(
  context: context,
  position: details.globalPosition,
  items: [...],
  config: ContextMenuConfig(
    backgroundColor: Colors.grey[900]!,
    hoverColor: Colors.grey[700]!,
    textStyle: TextStyle(color: Colors.white),
    elevation: 12.0,
    animationBuilder: ContextMenuAnimations.slideUp,
    animationDuration: Duration(milliseconds: 300),
  ),
);
```

### With SVG Icons

```dart
import 'package:flutter_svg/flutter_svg.dart';

ContextMenuItem(
  label: 'Export',
  icon: SvgPicture.asset(
    'assets/export.svg',
    width: 18,
    height: 18,
  ),
  onTap: () => print('Export'),
)
```

### Custom Menu Width

```dart
showContextMenu(
  config: ContextMenuConfig(
    minWidth: 200,
    maxWidth: 350,
  ),
  items: [...],
);
```

## Available Animations

- `ContextMenuAnimations.popup` - Scale + fade (default)
- `ContextMenuAnimations.fade` - Fade in only
- `ContextMenuAnimations.slideUp` - Slide from bottom
- `ContextMenuAnimations.slideDown` - Slide from top
- `ContextMenuAnimations.slideRight` - Slide from left
- `ContextMenuAnimations.bounce` - Elastic bounce effect
- `ContextMenuAnimations.scale` - Scale only
- `ContextMenuAnimations.none` - No animation

### Custom Animation

```dart
config: ContextMenuConfig(
  animationBuilder: (progress, child) {
    return Transform.rotate(
      angle: (1 - progress) * 3.14 / 2,
      child: Opacity(opacity: progress, child: child),
    );
  },
)
```

## Configuration Options

```dart
ContextMenuConfig(
  backgroundColor: Colors.white,        // Menu background color
  hoverColor: Color(0xFFE0E0E0),       // Item hover color
  textStyle: TextStyle(fontSize: 14),  // Text style
  itemHeight: 40.0,                    // Height of each item
  minWidth: 180.0,                     // Minimum menu width
  maxWidth: 280.0,                     // Maximum menu width
  itemPadding: EdgeInsets.symmetric(horizontal: 16.0),
  borderRadius: BorderRadius.circular(8.0),
  elevation: 8.0,                      // Shadow elevation
  animationDuration: Duration(milliseconds: 200),
  animationBuilder: ContextMenuAnimations.popup,
)
```

## Example App

Run the example app to see an interactive playground with all customization options:

```bash
cd example
flutter run
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
