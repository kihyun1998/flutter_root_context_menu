# Custom Widget Items

Use `ContextMenuItem.custom()` to embed interactive widgets inside menu items. Custom items do **not** auto-close the menu on interaction.

## Basic Usage

```dart
ContextMenuItem.custom(
  builder: (context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Icon(Icons.dark_mode, size: 18),
        SizedBox(width: 8),
        Expanded(child: Text('Dark Mode')),
        Switch(
          value: isDark,
          onChanged: (v) { ... },
        ),
      ],
    ),
  ),
)
```

## Custom Height

Override the default `itemHeight` for a specific custom item:

```dart
ContextMenuItem.custom(
  customHeight: 60,
  builder: (context) => MyTallWidget(),
)
```

## State Management in Custom Items

The context menu renders in a **separate overlay widget tree**. This means parent `setState()` won't rebuild the menu UI. You need a state mechanism that works across widget trees.

### ValueNotifier (No dependencies)

```dart
final ValueNotifier<bool> _darkMode = ValueNotifier(false);

ContextMenuItem.custom(
  builder: (context) => ValueListenableBuilder<bool>(
    valueListenable: _darkMode,
    builder: (context, value, _) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.dark_mode, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text('Dark Mode')),
          Switch(
            value: value,
            onChanged: (v) => _darkMode.value = v,
          ),
        ],
      ),
    ),
  ),
),
```

### Riverpod

Wrap the builder content with `Consumer` to watch providers inside the overlay:

```dart
ContextMenuItem.custom(
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final isDark = ref.watch(darkModeProvider);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.dark_mode, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Dark Mode')),
            Switch(
              value: isDark,
              onChanged: (v) {
                ref.read(darkModeProvider.notifier).state = v;
              },
            ),
          ],
        ),
      );
    },
  ),
),
```

### Provider / Bloc

Same pattern applies. Use `Consumer` (Provider) or `BlocBuilder` (Bloc):

```dart
// Provider
ContextMenuItem.custom(
  builder: (context) => Consumer<ThemeModel>(
    builder: (context, theme, _) => Switch(
      value: theme.isDark,
      onChanged: (v) => theme.toggleDark(),
    ),
  ),
),

// Bloc
ContextMenuItem.custom(
  builder: (context) => BlocBuilder<ThemeCubit, ThemeState>(
    builder: (context, state) => Switch(
      value: state.isDark,
      onChanged: (v) => context.read<ThemeCubit>().toggle(),
    ),
  ),
),
```

> **Why this works:** `Consumer`, `BlocBuilder`, etc. use `InheritedWidget` lookup which traverses up to `ProviderScope` / `BlocProvider` at the root — the overlay shares the same root, so it can access these ancestors.
