import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

class PlaygroundSettings {
  // Animation settings
  ContextMenuAnimationBuilder selectedAnimation;
  String animationName;
  double animationDuration;

  // Style settings
  Color backgroundColor;
  Color hoverColor;
  Color textColor;
  double elevation;
  double itemHeight;
  double minWidth;
  double maxWidth;

  // Screen padding settings
  double paddingTop;
  double paddingBottom;
  double paddingLeft;
  double paddingRight;

  // Item styling settings
  double itemBorderRadius;
  double itemMarginHorizontal;
  double itemMarginVertical;

  // Divider and menu styling settings
  double dividerMarginVertical;
  double menuPaddingHorizontal;
  double menuPaddingVertical;

  // Submenu settings
  ContextMenuAnimationBuilder? submenuAnimation;
  String submenuAnimationName;
  double submenuAnimationDuration;
  bool useSubmenuAnimationDuration;
  double submenuOpenDelay;
  double submenuCloseDelay;
  double submenuHorizontalOffset;
  int maxSubmenuDepth;

  // BoxShadow settings
  bool useCustomBoxShadow;
  double shadowBlurRadius;
  double shadowOffsetX;
  double shadowOffsetY;
  double shadowSpreadRadius;
  double shadowOpacity;
  Color shadowColor;

  PlaygroundSettings({
    this.selectedAnimation = ContextMenuAnimations.popup,
    this.animationName = 'Popup',
    this.animationDuration = 200,
    this.backgroundColor = Colors.white,
    this.hoverColor = const Color(0xFFE0E0E0),
    this.textColor = Colors.black,
    this.elevation = 8.0,
    this.itemHeight = 40.0,
    this.minWidth = 180.0,
    this.maxWidth = 280.0,
    this.paddingTop = 0,
    this.paddingBottom = 10,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.itemBorderRadius = 0,
    this.itemMarginHorizontal = 0,
    this.itemMarginVertical = 0,
    this.dividerMarginVertical = 0,
    this.menuPaddingHorizontal = 0,
    this.menuPaddingVertical = 0,
    this.submenuAnimation,
    this.submenuAnimationName = 'Auto',
    this.submenuAnimationDuration = 200,
    this.useSubmenuAnimationDuration = false,
    this.submenuOpenDelay = 200,
    this.submenuCloseDelay = 300,
    this.submenuHorizontalOffset = -4,
    this.maxSubmenuDepth = 5,
    this.useCustomBoxShadow = false,
    this.shadowBlurRadius = 10.0,
    this.shadowOffsetX = 0.0,
    this.shadowOffsetY = 4.0,
    this.shadowSpreadRadius = 0.0,
    this.shadowOpacity = 0.2,
    this.shadowColor = Colors.black,
  });

  static const Map<String, ContextMenuAnimationBuilder> animations = {
    'Popup': ContextMenuAnimations.popup,
    'Fade': ContextMenuAnimations.fade,
    'Slide Up': ContextMenuAnimations.slideUp,
    'Slide Down': ContextMenuAnimations.slideDown,
    'Slide Right': ContextMenuAnimations.slideRight,
    'Bounce': ContextMenuAnimations.bounce,
    'Scale': ContextMenuAnimations.scale,
    'None': ContextMenuAnimations.none,
  };

  static const Map<String, ContextMenuAnimationBuilder?> submenuAnimations = {
    'Auto': null,
    'Slide Right': ContextMenuAnimations.slideRight,
    'Slide Left': ContextMenuAnimations.slideLeft,
    'Fade': ContextMenuAnimations.fade,
    'Popup': ContextMenuAnimations.popup,
    'Slide Up': ContextMenuAnimations.slideUp,
    'Slide Down': ContextMenuAnimations.slideDown,
    'Bounce': ContextMenuAnimations.bounce,
    'Scale': ContextMenuAnimations.scale,
    'None': ContextMenuAnimations.none,
  };

  ContextMenuConfig toConfig() {
    return ContextMenuConfig(
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      textStyle: TextStyle(color: textColor, fontSize: 14),
      elevation: elevation,
      itemHeight: itemHeight,
      minWidth: minWidth,
      maxWidth: maxWidth,
      animationBuilder: selectedAnimation,
      animationDuration: Duration(milliseconds: animationDuration.toInt()),
      screenPadding: EdgeInsets.only(
        top: paddingTop,
        bottom: paddingBottom,
        left: paddingLeft,
        right: paddingRight,
      ),
      itemBorderRadius: BorderRadius.circular(itemBorderRadius),
      itemMargin: EdgeInsets.symmetric(
        horizontal: itemMarginHorizontal,
        vertical: itemMarginVertical,
      ),
      dividerMargin: EdgeInsets.symmetric(vertical: dividerMarginVertical),
      menuPadding: EdgeInsets.symmetric(
        horizontal: menuPaddingHorizontal,
        vertical: menuPaddingVertical,
      ),
      boxShadow: useCustomBoxShadow
          ? [
              BoxShadow(
                color: shadowColor.withValues(alpha: shadowOpacity),
                blurRadius: shadowBlurRadius,
                spreadRadius: shadowSpreadRadius,
                offset: Offset(shadowOffsetX, shadowOffsetY),
              ),
            ]
          : null,
      submenuOpenDelay: Duration(milliseconds: submenuOpenDelay.toInt()),
      submenuCloseDelay: Duration(milliseconds: submenuCloseDelay.toInt()),
      submenuHorizontalOffset: submenuHorizontalOffset,
      submenuAnimationBuilder: submenuAnimation,
      submenuAnimationDuration: useSubmenuAnimationDuration
          ? Duration(milliseconds: submenuAnimationDuration.toInt())
          : null,
      maxSubmenuDepth: maxSubmenuDepth,
    );
  }
}
