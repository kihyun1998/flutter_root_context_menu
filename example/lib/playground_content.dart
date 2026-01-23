import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

import 'main.dart';

/// Separated widget example - uses its own context for showContextMenu
/// This works because PlaygroundContent is inside ContextMenuArea,
/// so ContextMenuArea.of(context) finds the ancestor correctly.
class PlaygroundContent extends StatelessWidget {
  final String lastAction;
  final ValueChanged<String> onActionChanged;
  final ContextMenuConfig config;

  const PlaygroundContent({
    super.key,
    required this.lastAction,
    required this.onActionChanged,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        // Using this widget's own context - works because we're inside ContextMenuArea!
        showRootContextMenu(
          context: context,
          position: details.globalPosition,
          items: [
            ContextMenuItem(
              label: 'Copy',
              icon: const Icon(Icons.copy, size: 18),
              onTap: () => onActionChanged('Copy clicked'),
            ),
            ContextMenuItem(
              label: 'Paste',
              icon: const Icon(Icons.paste, size: 18),
              onTap: () => onActionChanged('Paste clicked'),
            ),
            ContextMenuItem(
              label: 'Cut',
              icon: const Icon(Icons.cut, size: 18),
              onTap: () => onActionChanged('Cut clicked'),
            ),
            ContextMenuItem.divider(),
            ContextMenuItem(
              label: 'Select All',
              icon: const Icon(Icons.select_all, size: 18),
              onTap: () => onActionChanged('Select All clicked'),
            ),
            ContextMenuItem(
              label: 'Refresh',
              icon: const Icon(Icons.refresh, size: 18),
              onTap: () => onActionChanged('Refresh clicked'),
            ),
            ContextMenuItem.divider(),
            ContextMenuItem(
              label: 'Delete',
              icon: const Icon(Icons.delete, size: 18),
              textColor: Colors.red,
              onTap: () => onActionChanged('Delete clicked'),
            ),
            ContextMenuItem.divider(),
            ContextMenuItem(
              label: 'Load Data (Async)',
              icon: const Icon(Icons.cloud_download, size: 18),
              onTap: () async {
                onActionChanged('Loading data...');
                await Future.delayed(const Duration(seconds: 2));
                onActionChanged('Data loaded successfully!');
              },
            ),
            ContextMenuItem(
              label: 'Save (Async)',
              icon: const Icon(Icons.save, size: 18),
              onTap: () async {
                onActionChanged('Saving...');
                await Future.delayed(const Duration(milliseconds: 1500));
                onActionChanged('Saved!');
              },
            ),
            ContextMenuItem.divider(),
            ContextMenuItem(
              label: 'Open New Screen',
              icon: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
            ),
          ],
          config: config,
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mouse, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Playground Area',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Right-click anywhere here to test',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Last Action:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastAction,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Test Route Observer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try: Open context menu, then click this button',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
