import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Full-screen layer under the menu panels that reports pointer-downs outside
/// the menu.
///
/// When [blocking] is false, pointers pass through to widgets below. When
/// [blocking] is true, the layer absorbs them; if [passSecondaryClick] is also
/// true, a secondary-button pointer-down is forwarded to the widgets below it
/// in the same [Overlay].
class ContextMenuOutsideLayer extends LeafRenderObjectWidget {
  final bool blocking;
  final bool passSecondaryClick;
  final VoidCallback onPointerDown;

  const ContextMenuOutsideLayer({
    super.key,
    required this.blocking,
    required this.passSecondaryClick,
    required this.onPointerDown,
  });

  @override
  RenderContextMenuOutsideLayer createRenderObject(BuildContext context) {
    return RenderContextMenuOutsideLayer(
      blocking: blocking,
      passSecondaryClick: passSecondaryClick,
      onPointerDown: onPointerDown,
      overlay: Overlay.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContextMenuOutsideLayer renderObject,
  ) {
    renderObject
      ..blocking = blocking
      ..passSecondaryClick = passSecondaryClick
      ..onPointerDown = onPointerDown
      ..overlay = Overlay.of(context);
  }
}

/// Render object for [ContextMenuOutsideLayer].
class RenderContextMenuOutsideLayer extends RenderBox {
  bool blocking;
  bool passSecondaryClick;
  VoidCallback onPointerDown;
  OverlayState overlay;

  bool _forwarding = false;

  RenderContextMenuOutsideLayer({
    required this.blocking,
    required this.passSecondaryClick,
    required this.onPointerDown,
    required this.overlay,
  });

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_forwarding || !size.contains(position)) return false;
    result.add(BoxHitTestEntry(this, position));
    return blocking;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is! PointerDownEvent) return;
    onPointerDown();
    if (blocking &&
        passSecondaryClick &&
        event.buttons & kSecondaryMouseButton != 0) {
      _forwardToWidgetsBelow(event);
    }
  }

  void _forwardToWidgetsBelow(PointerDownEvent event) {
    final overlayBox = overlay.context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.attached) return;

    final result = BoxHitTestResult();
    _forwarding = true;
    try {
      result.addWithPaintTransform(
        transform: overlayBox.getTransformTo(null),
        position: event.position,
        hitTest: (result, position) =>
            overlayBox.hitTest(result, position: position),
      );
    } finally {
      _forwarding = false;
    }

    for (final target in result.path) {
      target.target.handleEvent(event.transformed(target.transform), target);
    }
  }
}
