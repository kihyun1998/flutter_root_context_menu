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
}
