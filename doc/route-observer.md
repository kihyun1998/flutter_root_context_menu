# Route Observer & Manual Control

## Auto-close on Route Changes

Add `ContextMenuRouteObserver` to your `MaterialApp` to automatically close menus on navigation:

```dart
MaterialApp(
  navigatorObservers: [
    ContextMenuRouteObserver(),
  ],
  home: MyHomePage(),
)
```

Menus are closed on:
- `Navigator.push`
- `Navigator.pop`
- `Navigator.pushReplacement`
- Route removal

## Manual Control

### Helper Functions

```dart
// Close the menu
closeRootContextMenu();

// Check if a menu is open
if (isRootContextMenuOpen()) {
  print('Menu is open');
}
```

### Common Pattern: Close Before Navigation

```dart
ElevatedButton(
  onPressed: () {
    closeRootContextMenu();
    Navigator.push(context, MaterialPageRoute(...));
  },
  child: Text('Navigate'),
)
```

### Direct Controller Access

```dart
RootContextMenuController().hideMenu();
bool isOpen = RootContextMenuController().isMenuOpen;
```
