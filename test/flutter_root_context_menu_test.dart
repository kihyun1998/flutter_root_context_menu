import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

void main() {
  group('Context Menu Helper Functions', () {
    testWidgets('closeRootContextMenu closes an open menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenuArea(
              builder: (context) => GestureDetector(
                onTap: () {
                  showRootContextMenu(
                    context: context,
                    position: const Offset(100, 100),
                    items: [
                      ContextMenuItem(
                        label: 'Test Item',
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      // Verify menu is open
      expect(isRootContextMenuOpen(), true);
      expect(find.text('Test Item'), findsOneWidget);

      // Close menu explicitly
      closeRootContextMenu();
      await tester.pumpAndSettle();

      // Verify menu is closed
      expect(isRootContextMenuOpen(), false);
      expect(find.text('Test Item'), findsNothing);
    });

    testWidgets('isRootContextMenuOpen returns false when no menu is open',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      expect(isRootContextMenuOpen(), false);
    });

    testWidgets('isRootContextMenuOpen returns true when menu is open',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenuArea(
              builder: (context) => GestureDetector(
                onTap: () {
                  showRootContextMenu(
                    context: context,
                    position: const Offset(100, 100),
                    items: [
                      ContextMenuItem(
                        label: 'Test Item',
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      // Menu not open initially
      expect(isRootContextMenuOpen(), false);

      // Open menu
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      // Menu should be open
      expect(isRootContextMenuOpen(), true);
    });
  });
  group('useBarrier', () {
    const targetCenter = Offset(400, 400);
    const emptySpot = Offset(700, 50);

    late int targetTaps;
    late int targetHoverEnters;
    late int itemTaps;
    late int targetScrolls;

    Future<void> pumpAndOpen(WidgetTester tester, {bool? useBarrier}) async {
      targetTaps = 0;
      targetHoverEnters = 0;
      itemTaps = 0;
      targetScrolls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        final items = [
                          ContextMenuItem(
                            label: 'Test Item',
                            onTap: () => itemTaps++,
                          ),
                        ];
                        if (useBarrier == null) {
                          showRootContextMenu(
                            context: context,
                            position: const Offset(10, 10),
                            items: items,
                          );
                        } else {
                          showRootContextMenu(
                            context: context,
                            position: const Offset(10, 10),
                            items: items,
                            useBarrier: useBarrier,
                          );
                        }
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
                Positioned(
                  left: targetCenter.dx - 50,
                  top: targetCenter.dy - 50,
                  width: 100,
                  height: 100,
                  child: Listener(
                    onPointerSignal: (event) {
                      if (event is PointerScrollEvent) targetScrolls++;
                    },
                    child: MouseRegion(
                      onEnter: (_) => targetHoverEnters++,
                      child: GestureDetector(
                        onTap: () => targetTaps++,
                        child: const ColoredBox(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(isRootContextMenuOpen(), true);
    }

    Future<void> hoverTarget(WidgetTester tester) async {
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: emptySpot);
      await tester.pump();
      await gesture.moveTo(targetCenter);
      await tester.pump();
    }

    Future<void> scrollTarget(WidgetTester tester) async {
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(targetCenter));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
      await tester.pump();
    }

    tearDown(closeRootContextMenu);

    testWidgets(
        'on: tap outside closes the menu without reaching widgets below',
        (tester) async {
      await pumpAndOpen(tester, useBarrier: true);

      await tester.tapAt(targetCenter);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), false);
      expect(targetTaps, 0);
    });

    testWidgets('on: hover outside does not reach widgets below',
        (tester) async {
      await pumpAndOpen(tester, useBarrier: true);

      await hoverTarget(tester);

      expect(targetHoverEnters, 0);
    });

    testWidgets('on: scroll outside does not reach widgets below',
        (tester) async {
      await pumpAndOpen(tester, useBarrier: true);

      await scrollTarget(tester);

      expect(targetScrolls, 0);
    });

    testWidgets('on: menu items still work', (tester) async {
      await pumpAndOpen(tester, useBarrier: true);

      await tester.tap(find.text('Test Item'));
      await tester.pumpAndSettle();

      expect(itemTaps, 1);
      expect(isRootContextMenuOpen(), false);
    });

    testWidgets('on: closing the menu removes the barrier', (tester) async {
      await pumpAndOpen(tester, useBarrier: true);

      closeRootContextMenu();
      await tester.pumpAndSettle();
      await tester.tapAt(targetCenter);
      await tester.pump();

      expect(targetTaps, 1);
    });

    testWidgets(
        'default: tap outside closes the menu and reaches widgets below',
        (tester) async {
      await pumpAndOpen(tester);

      await tester.tapAt(targetCenter);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), false);
      expect(targetTaps, 1);
    });

    testWidgets('default: hover outside reaches widgets below', (tester) async {
      await pumpAndOpen(tester);

      await hoverTarget(tester);

      expect(targetHoverEnters, 1);
    });

    testWidgets('default: scroll outside reaches widgets below',
        (tester) async {
      await pumpAndOpen(tester);

      await scrollTarget(tester);

      expect(targetScrolls, 1);
    });
  });
  group('barrierPassesSecondaryClick', () {
    const firstSpot = Offset(100, 100);
    const secondSpot = Offset(400, 400);
    const emptySpot = Offset(700, 300);

    late int menusOpened;
    late int areaTaps;
    late int areaHoverEnters;
    late int appPointerDowns;

    Future<void> pumpArea(
      WidgetTester tester, {
      required bool useBarrier,
      required bool passSecondary,
    }) async {
      menusOpened = 0;
      areaTaps = 0;
      areaHoverEnters = 0;
      appPointerDowns = 0;
      await tester.pumpWidget(
        Listener(
          onPointerDown: (_) => appPointerDowns++,
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 600,
                    height: 600,
                    child: Builder(
                      builder: (context) => MouseRegion(
                        onEnter: (_) => areaHoverEnters++,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => areaTaps++,
                          onSecondaryTapDown: (details) {
                            menusOpened++;
                            showRootContextMenu(
                              context: context,
                              position: details.globalPosition,
                              useBarrier: useBarrier,
                              barrierPassesSecondaryClick: passSecondary,
                              items: [
                                ContextMenuItem(
                                  label: 'Menu $menusOpened',
                                  onTap: () {},
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tapAt(firstSpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(find.text('Menu 1'), findsOneWidget);
      appPointerDowns = 0;
    }

    tearDown(closeRootContextMenu);

    testWidgets('on: one right-click elsewhere reopens the menu there',
        (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: true);

      await tester.tapAt(secondSpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), true);
      expect(find.text('Menu 1'), findsNothing);
      expect(find.text('Menu 2'), findsOneWidget);
      final menuTopLeft = tester.getTopLeft(find.text('Menu 2'));
      expect(menuTopLeft.dx, greaterThanOrEqualTo(secondSpot.dx));
      expect(menuTopLeft.dy, greaterThanOrEqualTo(secondSpot.dy));
    });

    testWidgets('on: widgets above the overlay see the right-click once',
        (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: true);

      await tester.tapAt(secondSpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(appPointerDowns, 1);
    });

    testWidgets('on: left-click outside is still blocked', (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: true);

      await tester.tapAt(secondSpot);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), false);
      expect(areaTaps, 0);
    });

    testWidgets('on: hover outside is still blocked', (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: true);
      areaHoverEnters = 0;

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: emptySpot);
      await tester.pump();
      await gesture.moveTo(secondSpot);
      await tester.pump();

      expect(areaHoverEnters, 0);
    });

    testWidgets('on: right-click where nothing listens just closes the menu',
        (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: true);

      await tester.tapAt(emptySpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), false);
      expect(menusOpened, 1);
    });

    testWidgets('off: right-click elsewhere only closes the barrier menu',
        (tester) async {
      await pumpArea(tester, useBarrier: true, passSecondary: false);

      await tester.tapAt(secondSpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(isRootContextMenuOpen(), false);
      expect(menusOpened, 1);
    });

    testWidgets('without useBarrier: right-click elsewhere reopens as before',
        (tester) async {
      await pumpArea(tester, useBarrier: false, passSecondary: true);

      await tester.tapAt(secondSpot, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(find.text('Menu 2'), findsOneWidget);
      expect(appPointerDowns, 1);
    });
  });
}
