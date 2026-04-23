# Basic Usage & Styling

## Basic Example

The recommended approach is to use `ContextMenuArea` with `builder` for correct context handling:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

ContextMenuArea(
  builder: (context) => GestureDetector(
    onSecondaryTapDown: (details) {
      showRootContextMenu(
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

## Custom Styling

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

## Custom Box Shadow

When `boxShadow` is set, `elevation` is ignored:

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

## SVG Icons

Any widget can be used as an icon:

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

## Disabled Items

```dart
ContextMenuItem(
  label: 'Cannot click this',
  icon: Icon(Icons.block, size: 18),
  enabled: false,
  onTap: () => print('This won\'t be called'),
)
```

### Customizing Disabled Text

Use `disabledTextStyle` on `ContextMenuConfig` to control how the label text
of disabled items looks.

```dart
ContextMenuConfig(
  disabledTextStyle: TextStyle(
    fontSize: 14,
    color: Colors.grey.shade400,
    fontStyle: FontStyle.italic,
  ),
)
```

- When set, replaces `textStyle` for disabled items and ignores
  `ContextMenuItem.textColor`.
- When `null`, falls back to `textStyle.copyWith(color: Colors.grey)`.

**Icons are rendered as-is regardless of `enabled`.** If you want an icon to
visually reflect the disabled state, build it conditionally at call-site:

```dart
ContextMenuItem(
  label: 'Cut',
  icon: Icon(Icons.content_cut, size: 18, color: Colors.grey),
  enabled: false,
)
```

## macOS-style Preset

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
