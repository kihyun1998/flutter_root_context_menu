import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

import '../pages/second_page.dart';

/// Separated widget example - uses its own context for showContextMenu
/// This works because PlaygroundContent is inside ContextMenuArea,
/// so ContextMenuArea.of(context) finds the ancestor correctly.
class PlaygroundContent extends StatefulWidget {
  final String lastAction;
  final ValueChanged<String> onActionChanged;
  final ContextMenuConfig config;
  final String? title;
  final Color disabledIconColor;

  const PlaygroundContent({
    super.key,
    required this.lastAction,
    required this.onActionChanged,
    required this.config,
    required this.disabledIconColor,
    this.title,
  });

  @override
  State<PlaygroundContent> createState() => _PlaygroundContentState();
}

class _PlaygroundContentState extends State<PlaygroundContent> {
  final ValueNotifier<bool> _darkMode = ValueNotifier(false);
  final ValueNotifier<bool> _notifications = ValueNotifier(true);
  final ValueNotifier<double> _volume = ValueNotifier(0.5);

  @override
  void dispose() {
    _darkMode.dispose();
    _notifications.dispose();
    _volume.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        showRootContextMenu(
          context: context,
          position: details.globalPosition,
          title: widget.title,
          items: [
            ContextMenuItem(
              label: 'Copy',
              icon: const Icon(Icons.copy, size: 18),
              onTap: () => widget.onActionChanged('Copy clicked'),
            ),
            ContextMenuItem(
              label: 'Paste',
              icon: const Icon(Icons.paste, size: 18),
              onTap: () => widget.onActionChanged('Paste clicked'),
            ),
            // Disabled items: icons are rendered as-is by the library,
            // so color them at call-site to reflect the disabled state.
            ContextMenuItem(
              label: 'Cut (disabled)',
              icon: Icon(
                Icons.content_cut,
                size: 18,
                color: widget.disabledIconColor,
              ),
              enabled: false,
              onTap: () => widget.onActionChanged('Cut clicked'),
            ),
            ContextMenuItem.submenu(
              label: 'Archive (disabled)',
              icon: Icon(
                Icons.archive,
                size: 18,
                color: widget.disabledIconColor,
              ),
              enabled: false,
              children: const [ContextMenuItem(label: 'Never shown')],
            ),
            ContextMenuItem.divider(),
            ContextMenuItem.custom(
              builder: (context) => ValueListenableBuilder<bool>(
                valueListenable: _darkMode,
                builder: (context, value, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.dark_mode, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Dark Mode')),
                      SizedBox(
                        height: 24,
                        child: Switch(
                          value: value,
                          onChanged: (v) {
                            _darkMode.value = v;
                            widget.onActionChanged(
                              'Dark Mode ${v ? "ON" : "OFF"}',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ContextMenuItem.custom(
              customHeight: 60,
              builder: (context) => ValueListenableBuilder<double>(
                valueListenable: _volume,
                builder: (context, value, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volume_up, size: 18),
                          const SizedBox(width: 8),
                          Text('Volume: ${(value * 100).round()}%'),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                        child: Slider(
                          value: value,
                          onChanged: (v) {
                            _volume.value = v;
                            widget.onActionChanged(
                              'Volume: ${(v * 100).round()}%',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ContextMenuItem.custom(
              customHeight: 80,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.palette, size: 18),
                        SizedBox(width: 8),
                        Text('Theme Color'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(
                        10,
                        (i) => GestureDetector(
                          onTap: () =>
                              widget.onActionChanged('Color ${i + 1} selected'),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.primaries[i],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ContextMenuItem.divider(),
            ContextMenuItem.submenu(
              label: 'Share',
              icon: const Icon(Icons.share, size: 18),
              children: [
                ContextMenuItem(
                  label: 'Email',
                  icon: const Icon(Icons.email, size: 18),
                  onTap: () => widget.onActionChanged('Share via Email'),
                ),
                ContextMenuItem(
                  label: 'Slack',
                  icon: const Icon(Icons.chat, size: 18),
                  onTap: () => widget.onActionChanged('Share via Slack'),
                ),
                ContextMenuItem.divider(),
                ContextMenuItem.submenu(
                  label: 'Social',
                  icon: const Icon(Icons.public, size: 18),
                  children: [
                    ContextMenuItem(
                      label: 'Twitter',
                      onTap: () => widget.onActionChanged('Share on Twitter'),
                    ),
                    ContextMenuItem(
                      label: 'Facebook',
                      onTap: () => widget.onActionChanged('Share on Facebook'),
                    ),
                    ContextMenuItem(
                      label: 'LinkedIn',
                      onTap: () => widget.onActionChanged('Share on LinkedIn'),
                    ),
                  ],
                ),
              ],
            ),
            ContextMenuItem.submenu(
              label: 'Export As',
              icon: const Icon(Icons.download, size: 18),
              children: [
                ContextMenuItem(
                  label: 'PNG',
                  onTap: () => widget.onActionChanged('Export as PNG'),
                ),
                ContextMenuItem(
                  label: 'PDF',
                  onTap: () => widget.onActionChanged('Export as PDF'),
                ),
                ContextMenuItem(
                  label: 'SVG',
                  onTap: () => widget.onActionChanged('Export as SVG'),
                ),
              ],
            ),
            ContextMenuItem.divider(),
            ContextMenuItem(
              label: 'Delete',
              icon: const Icon(Icons.delete, size: 18),
              textColor: Colors.red,
              onTap: () => widget.onActionChanged('Delete clicked'),
            ),
          ],
          config: widget.config,
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
                    widget.lastAction,
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
                if (isRootContextMenuOpen()) {
                  closeRootContextMenu();
                }
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
