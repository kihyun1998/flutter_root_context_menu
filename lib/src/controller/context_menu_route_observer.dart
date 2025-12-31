import 'package:flutter/material.dart';
import 'context_menu_controller.dart';

/// A [NavigatorObserver] that automatically closes context menus when routes change.
///
/// This observer ensures that context menus are closed when:
/// - A new route is pushed onto the navigator
/// - A route is popped from the navigator
/// - A route is replaced
/// - A route is removed
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     ContextMenuRouteObserver(),
///   ],
///   home: MyHomePage(),
/// )
/// ```
class ContextMenuRouteObserver extends NavigatorObserver {
  /// Creates a [ContextMenuRouteObserver].
  ContextMenuRouteObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RootContextMenuController().hideMenu();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RootContextMenuController().hideMenu();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RootContextMenuController().hideMenu();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    RootContextMenuController().hideMenu();
  }
}
