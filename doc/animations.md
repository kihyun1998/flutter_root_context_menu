# Animations

## Built-in Animations

All animations are accessed via `ContextMenuAnimations`:

| Animation | Effect |
|-----------|--------|
| `popup` | Scale + fade (default) |
| `fade` | Fade in only |
| `slideUp` | Slide from bottom |
| `slideDown` | Slide from top |
| `slideRight` | Slide from left |
| `bounce` | Elastic bounce effect |
| `scale` | Scale only |
| `none` | No animation |

```dart
showRootContextMenu(
  config: ContextMenuConfig(
    animationBuilder: ContextMenuAnimations.slideUp,
    animationDuration: Duration(milliseconds: 300),
  ),
  items: [...],
);
```

## Custom Animation

Create your own animation by providing a `ContextMenuAnimationBuilder`:

```dart
config: ContextMenuConfig(
  animationBuilder: (progress, child) {
    // progress: 0.0 (start) -> 1.0 (end)
    return Transform.rotate(
      angle: (1 - progress) * 3.14 / 2,
      child: Opacity(opacity: progress, child: child),
    );
  },
)
```

The builder receives:
- `progress` (`double`) — animation value from 0.0 to 1.0
- `child` (`Widget`) — the menu widget to transform
