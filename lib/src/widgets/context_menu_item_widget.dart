import 'package:flutter/material.dart';
import '../controller/context_menu_controller.dart';
import '../models/context_menu_config.dart';
import '../models/context_menu_item.dart';

/// Widget that renders a single context menu item.
class ContextMenuItemWidget extends StatefulWidget {
  final ContextMenuItem item;
  final ContextMenuConfig config;

  const ContextMenuItemWidget({
    super.key,
    required this.item,
    required this.config,
  });

  @override
  State<ContextMenuItemWidget> createState() => _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<ContextMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Render divider
    if (widget.item.isDivider) {
      return const Divider(height: 1, thickness: 1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.item.enabled
            ? () {
                widget.item.onTap?.call();
                RootContextMenuController().hideMenu();
              }
            : null,
        child: Container(
          height: widget.config.itemHeight,
          padding: widget.config.itemPadding,
          color: _isHovered && widget.item.enabled
              ? widget.config.hoverColor
              : null,
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Opacity(
                  opacity: widget.item.enabled ? 1.0 : 0.4,
                  child: widget.item.icon,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: widget.config.textStyle.copyWith(
                    color: widget.item.enabled
                        ? widget.item.textColor
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
