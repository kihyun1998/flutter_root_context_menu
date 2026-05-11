import 'package:flutter/material.dart';
import '../controller/context_menu_controller.dart';
import '../models/context_menu_config.dart';
import '../models/context_menu_item.dart';

/// Widget that renders a single context menu item.
class ContextMenuItemWidget extends StatefulWidget {
  final ContextMenuItem item;
  final ContextMenuConfig config;
  final int itemIndex;
  final bool isActiveSubmenuParent;
  final void Function(GlobalKey itemKey)? onSubmenuHoverEnter;
  final VoidCallback? onSubmenuHoverExit;
  final VoidCallback? onNonSubmenuItemHoverEnter;

  const ContextMenuItemWidget({
    super.key,
    required this.item,
    required this.config,
    this.itemIndex = 0,
    this.isActiveSubmenuParent = false,
    this.onSubmenuHoverEnter,
    this.onSubmenuHoverExit,
    this.onNonSubmenuItemHoverEnter,
  });

  @override
  State<ContextMenuItemWidget> createState() => _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<ContextMenuItemWidget> {
  bool _isHovered = false;
  final GlobalKey _itemKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Render divider
    if (widget.item.isDivider) {
      return Padding(
        padding: widget.config.dividerMargin,
        child: const Divider(height: 1, thickness: 1),
      );
    }

    // Render custom widget with its own state scope
    if (widget.item.isCustom) {
      return Padding(
        padding: widget.config.itemMargin,
        child: SizedBox(
          height: widget.item.customHeight ?? widget.config.itemHeight,
          child: StatefulBuilder(
            builder: (context, setInnerState) => widget.item.builder!(context),
          ),
        ),
      );
    }

    return Padding(
      padding: widget.config.itemMargin,
      child: MouseRegion(
        cursor: widget.item.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) {
          setState(() => _isHovered = true);
          if (widget.item.isSubmenu && widget.item.enabled) {
            widget.onSubmenuHoverEnter?.call(_itemKey);
          } else if (!widget.item.isSubmenu && !widget.item.isDivider) {
            widget.onNonSubmenuItemHoverEnter?.call();
          }
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          if (widget.item.isSubmenu) {
            widget.onSubmenuHoverExit?.call();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.item.isSubmenu
              ? (widget.item.enabled
                  ? () => widget.onSubmenuHoverEnter?.call(_itemKey)
                  : null)
              : (widget.item.enabled
                  ? () {
                      RootContextMenuController().hideMenu();
                      final callback = widget.item.onTap;
                      if (callback != null) {
                        Future.microtask(() => callback.call());
                      }
                    }
                  : null),
          child: Container(
            key: _itemKey,
            height: widget.config.itemHeight,
            padding: widget.config.itemPadding,
            decoration: BoxDecoration(
              color: (_isHovered || widget.isActiveSubmenuParent) &&
                      widget.item.enabled
                  ? widget.config.hoverColor
                  : null,
              borderRadius: widget.config.itemBorderRadius,
            ),
            child: Row(
              children: [
                if (widget.item.icon != null) ...[
                  widget.config.iconWidth > 0
                      ? SizedBox(
                          width: widget.config.iconWidth,
                          child: widget.item.icon,
                        )
                      : widget.item.icon!,
                  if (widget.config.iconSpacing > 0)
                    SizedBox(width: widget.config.iconSpacing),
                ],
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: widget.item.enabled
                        ? widget.config.textStyle.copyWith(
                            color: widget.item.textColor,
                          )
                        : (widget.config.disabledTextStyle ??
                            widget.config.textStyle
                                .copyWith(color: Colors.grey)),
                  ),
                ),
                if (widget.item.isSubmenu)
                  widget.config.submenu.icon ??
                      const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
