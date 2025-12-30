import 'package:flutter/material.dart';

/// Function signature for custom context menu animations.
///
/// Takes an animation [progress] value from 0.0 to 1.0 and the menu [child],
/// and returns the animated widget.
typedef ContextMenuAnimationBuilder = Widget Function(
  double progress,
  Widget child,
);

/// Pre-defined context menu animations.
///
/// Use these built-in animations or create your own using
/// [ContextMenuAnimationBuilder].
class ContextMenuAnimations {
  /// Simple fade-in animation.
  ///
  /// The menu appears with increasing opacity from 0 to 1.
  static Widget fade(double progress, Widget child) {
    return Opacity(
      opacity: progress,
      child: child,
    );
  }

  /// Popup animation with scale and fade.
  ///
  /// The menu scales from 90% to 100% while fading in.
  /// This is the default animation.
  static Widget popup(double progress, Widget child) {
    return Opacity(
      opacity: progress,
      child: Transform.scale(
        scale: 0.9 + (0.1 * progress),
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }

  /// Slide up animation.
  ///
  /// The menu slides up from 20 pixels below while fading in.
  static Widget slideUp(double progress, Widget child) {
    return Transform.translate(
      offset: Offset(0, 20 * (1 - progress)),
      child: Opacity(
        opacity: progress,
        child: child,
      ),
    );
  }

  /// Slide down animation.
  ///
  /// The menu slides down from 20 pixels above while fading in.
  static Widget slideDown(double progress, Widget child) {
    return Transform.translate(
      offset: Offset(0, -20 * (1 - progress)),
      child: Opacity(
        opacity: progress,
        child: child,
      ),
    );
  }

  /// Slide right animation.
  ///
  /// The menu slides in from the left while fading in.
  static Widget slideRight(double progress, Widget child) {
    return Transform.translate(
      offset: Offset(-20 * (1 - progress), 0),
      child: Opacity(
        opacity: progress,
        child: child,
      ),
    );
  }

  /// Bounce animation with elastic effect.
  ///
  /// The menu bounces in with an elastic curve.
  static Widget bounce(double progress, Widget child) {
    final curve = Curves.elasticOut.transform(progress);
    return Transform.scale(
      scale: curve,
      alignment: Alignment.topLeft,
      child: Opacity(
        opacity: progress,
        child: child,
      ),
    );
  }

  /// Scale animation without fade.
  ///
  /// The menu scales from 0% to 100% without opacity change.
  static Widget scale(double progress, Widget child) {
    return Transform.scale(
      scale: progress,
      alignment: Alignment.topLeft,
      child: child,
    );
  }

  /// No animation.
  ///
  /// The menu appears instantly without any transition.
  static Widget none(double progress, Widget child) {
    return child;
  }
}
