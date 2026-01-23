# flutter_root_context_menu

A customizable context menu package for Flutter with animation support, flexible styling, and web-like behavior.

## Features

- 🎯 **Manual Trigger** - Full control over when and where to show menus
- 🎨 **Flexible Icons** - Support for Material Icons, SVG, images, and custom widgets
- ✨ **8 Built-in Animations** - Fade, popup, slide, bounce, scale, and more
- 🎭 **Custom Animations** - Create your own animation effects
- 📐 **Customizable Styling** - Colors, sizes, elevation, border radius, width, and custom shadows
- 🖱️ **Web-like Behavior** - Single click closes menu and triggers action simultaneously
- 📍 **Smart Positioning** - Automatic overflow prevention
- 🎮 **Interactive Example** - Try the playground app to test all features

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_root_context_menu: ^0.4.1
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

// Recommended: Use builder parameter for correct context handling
ContextMenuArea(
  builder: (context) => GestureDetector(
    onSecondaryTapDown: (details) {
      showRootContextMenu(
        context: context,  // This context is inside ContextMenuArea
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
showRootContextMenu(
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

### With Custom Box Shadow

```dart
showRootContextMenu(
  context: context,
  position: details.globalPosition,
  items: [...],
  config: ContextMenuConfig(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 15,
        spreadRadius: 2,
        offset: Offset(0, 8),
      ),
    ],
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
showRootContextMenu(
  config: ContextMenuConfig(
    minWidth: 200,
    maxWidth: 350,
  ),
  items: [...],
);
```

### Screen Padding

```dart
showRootContextMenu(
  config: ContextMenuConfig(
    screenPadding: EdgeInsets.only(bottom: 10),
  ),
  items: [...],
);
```

## Area Constraints

Use `ContextMenuArea` to constrain the menu within a specific region. The menu will automatically reposition to stay inside this area.

### Using builder (Recommended)

```dart
ContextMenuArea(
  builder: (context) => Container(
    width: 400,
    height: 300,
    color: Colors.grey[200],
    child: GestureDetector(
      onSecondaryTapDown: (details) {
        showRootContextMenu(
          context: context,  // Uses the context provided by builder
          position: details.globalPosition,
          items: [...],
        );
      },
      child: Center(child: Text('Menu stays within this area')),
    ),
  ),
)
```

### Using child with separated widget

When your menu widget is separated into its own class, you can use the `child` parameter:

```dart
// Parent widget
ContextMenuArea(
  child: MyCustomWidget(),
)

// Separated widget - can use its own context
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        showRootContextMenu(
          context: context,  // This context finds ContextMenuArea ancestor
          position: details.globalPosition,
          items: [...],
        );
      },
      child: Container(...),
    );
  }
}
```

When the menu would overflow the `ContextMenuArea` bounds, it automatically repositions to stay inside.

## Disabled Items

You can disable menu items to make them non-interactive:

```dart
ContextMenuItem(
  label: 'Cannot click this',
  icon: Icon(Icons.block, size: 18),
  enabled: false,  // Item is grayed out and not clickable
  onTap: () => print('This won\'t be called'),
)
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

## Auto-close on Route Changes

To automatically close context menus when navigating between screens, add `ContextMenuRouteObserver` to your `MaterialApp`:

```dart
MaterialApp(
  navigatorObservers: [
    ContextMenuRouteObserver(),
  ],
  home: MyHomePage(),
)
```

This ensures menus are closed when:
- A new screen is pushed (`Navigator.push`)
- Going back to previous screen (`Navigator.pop`)
- Replacing routes (`Navigator.pushReplacement`)
- Removing routes

## Manual Control

You can also manually control the menu:

```dart
// Close the menu programmatically
RootContextMenuController().hideMenu();

// Check if a menu is currently open
bool isOpen = RootContextMenuController().isMenuOpen;
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
  elevation: 8.0,                      // Shadow elevation (ignored if boxShadow is set)
  animationDuration: Duration(milliseconds: 200),
  animationBuilder: ContextMenuAnimations.popup,
  screenPadding: EdgeInsets.zero,      // Padding from screen edges
  itemBorderRadius: BorderRadius.zero, // Border radius for item backgrounds
  itemMargin: EdgeInsets.zero,         // Margin around items
  dividerMargin: EdgeInsets.zero,      // Margin around dividers
  menuPadding: EdgeInsets.zero,        // Padding inside menu container
  iconWidth: 0,                        // Icon width (0 = natural size)
  iconSpacing: 0,                      // Spacing between icon and text
  boxShadow: null,                     // Custom box shadow (overrides elevation)
)
```

### macOS-style Menu

```dart
ContextMenuConfig(
  backgroundColor: Color(0xFFF5F5F5),
  hoverColor: Colors.blue,
  textStyle: TextStyle(fontSize: 13),
  itemHeight: 32.0,
  itemBorderRadius: BorderRadius.circular(4),
  itemMargin: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  menuPadding: EdgeInsets.symmetric(vertical: 6),
  iconWidth: 16.0,
  iconSpacing: 10.0,
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
