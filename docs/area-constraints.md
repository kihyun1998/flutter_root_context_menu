# Area Constraints

Use `ContextMenuArea` to constrain the menu within a specific region. The menu automatically repositions to stay inside the area bounds.

## Using builder (Recommended)

```dart
ContextMenuArea(
  builder: (context) => Container(
    width: 400,
    height: 300,
    color: Colors.grey[200],
    child: GestureDetector(
      onSecondaryTapDown: (details) {
        showRootContextMenu(
          context: context,
          position: details.globalPosition,
          items: [...],
        );
      },
      child: Center(child: Text('Menu stays within this area')),
    ),
  ),
)
```

## Using child with separated widget

When the menu widget is in a separate class, use the `child` parameter:

```dart
// Parent
ContextMenuArea(
  child: MyCustomWidget(),
)

// Child widget - uses its own context
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        showRootContextMenu(
          context: context,
          position: details.globalPosition,
          items: [...],
        );
      },
      child: Container(...),
    );
  }
}
```

## Screen Padding

Control minimum distance from screen edges:

```dart
showRootContextMenu(
  config: ContextMenuConfig(
    screenPadding: EdgeInsets.only(bottom: 10),
  ),
  items: [...],
);
```
