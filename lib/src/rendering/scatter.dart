import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// A delegate that controls the layout of a [Scatter].
abstract class ScatterDelegate {
  ScatterDelegate({
    this.ratio,
  });

  final double ratio;

  double _ratioX;
  double get ratioX => _ratioX;

  double _ratioY;
  double get ratioY => _ratioY;

  Size _availableSize;
  Size get availableSize => _availableSize;
  void _setAvailableSize(Size value) {
    _availableSize = value;
    final double ratio =
        this.ratio ?? (value.isFinite ? value.width / value.height : 1.0);
    _ratioX = ratio >= 1 ? ratio : 1.0;
    _ratioY = ratio <= 1 ? ratio : 1.0;
  }

  /// Returns an offset for the specified iteration.
  ///
  /// For a given iteration, the offset should be unique.
  Offset getPositionForIteration(int iteration, Size childSize);

  /// Override this method to return true when the children need to be laid out.
  /// This should compare the fields of the current delegate and the given
  /// oldDelegate and return true if the fields are such that the layout would
  /// be different.
  @mustCallSuper
  bool shouldRelayout(covariant ScatterDelegate oldDelegate) {
    return oldDelegate.ratio != ratio;
  }
}

// class FermatSpiralScatterDelegate extends ScatterDelegate {
//   FermatSpiralScatterDelegate({
//     double ratio,
//     this.dt = 3.0,
//   }) : super(ratio: ratio);

//   final double dt;

//   Offset getPositionForIteration(int iteration, Size childSize) {
//     final t = iteration * dt;
//     final double ratio = this.ratio ??
//         (availableSize.isFinite
//             ? availableSize.width / availableSize.height
//             : 1.0);
//     final double ratioX = ratio >= 1 ? ratio : 1.0;
//     final double ratioY = ratio <= 1 ? ratio : 1.0;
//     final double x = ratioX * t * math.cos(t);
//     final double y = ratioY * t * math.sin(t);
//     return Offset(x, y);
//   }

//   bool shouldRelayout(covariant FermatSpiralScatterDelegate oldDelegate) {
//     return oldDelegate.ratio != ratio || oldDelegate.dt != dt;
//   }
// }

// class ArchimedeanSpiralScatterDelegateOld extends ScatterDelegate {
//   ArchimedeanSpiralScatterDelegateOld({
//     ratio,
//     this.radius = 400.0,
//     this.sides = 400.0,
//     this.coils = 8.0,
//     double rotation = 0.5,
//   })  : awayStep = radius / sides,
//         aroundStep = coils / sides,
//         aroundRadians = coils * math.pi * 2 / sides,
//         rotation = rotation * 2 * math.pi;

//   final double radius;
//   final double sides;
//   final double coils;
//   final double rotation;

//   final double awayStep;
//   final double aroundStep;
//   final double aroundRadians;

//   Offset getPositionForIteration(
//       int iteration, Size childSize, Size availableSize) {
//     final double ratio = this.ratio ??
//         (availableSize.isFinite
//             ? availableSize.width / availableSize.height
//             : 1.0);
//     final double ratioX = ratio >= 1 ? ratio : 1.0;
//     final double ratioY = ratio <= 1 ? ratio : 1.0;

//     final double away = iteration * awayStep;
//     final double around = iteration * aroundRadians + rotation;
//     final double x = math.cos(around) * away * ratioX;
//     final double y = math.sin(around) * away * ratioY;
//     return Offset(x, y);
//   }

//   bool shouldRelayout(
//       covariant ArchimedeanSpiralScatterDelegateOld oldDelegate) {
//     return oldDelegate.radius != radius ||
//         oldDelegate.sides != sides ||
//         oldDelegate.coils != coils ||
//         oldDelegate.rotation != rotation ||
//         oldDelegate.ratio != ratio;
//   }
// }

class ArchimedeanSpiralScatterDelegate extends ScatterDelegate {
  static const double _2pi = math.pi * 2;

  ArchimedeanSpiralScatterDelegate({
    double ratio = 1.0,
    this.radius = 10.0,
    this.distance = 10.00,
    this.dt = 0.01,
    this.type = 2,
    double rotation = 0.0,
  })  : assert(type != null && type != 0),
        _rotationRadians = rotation * 2 * math.pi,
        super(ratio: ratio);

  /// The number of turns between two successive iterations.
  ///
  /// For example if dt=0.25, for each iteration
  /// θ will be increased by 0.25 * 2π.
  final double dt;

  /// The initial radius of the spiral.
  ///
  /// This is the **a** parameter in the equation **r = a+bθ**.
  final double radius;

  /// The distance between successive turns of the spiral.
  ///
  /// This is the **b** parameter in the equation **r = a+bθ**.
  final double distance;

  final double _rotationRadians;

  final int type;

  Offset getPositionForIteration(
    int iteration,
    Size childSize,
  ) {
    final double theta = iteration * dt * _2pi;
    final double r = radius + distance * theta;
    final double x = ratioX * r * math.cos(theta + _rotationRadians);
    final double y = ratioY * r * math.sin(theta + _rotationRadians);
    return Offset(x, y);
  }

  bool shouldRelayout(covariant ArchimedeanSpiralScatterDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.radius != radius ||
        oldDelegate.distance != distance ||
        oldDelegate.dt != dt ||
        oldDelegate._rotationRadians != _rotationRadians ||
        oldDelegate.type != type;
  }
}

class ScatterParentData extends ContainerBoxParentData<RenderBox> {
  // The index of the child in the children list.
  int index;

  /// The child's width.
  double width;

  /// The child's height.
  double height;

  Rect get rect => Rect.fromLTWH(
        offset.dx,
        offset.dy,
        width,
        height,
      );
}

class RenderScatter extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ScatterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ScatterParentData> {
  RenderScatter({
    @required ScatterDelegate delegate,
    @required Alignment alignment,
    List<RenderBox> children,
  })  : assert(delegate != null),
        assert(alignment != null),
        _delegate = delegate,
        _alignment = alignment {
    addAll(children);
  }

  bool _hasVisualOverflow = false;

  /// The delegate that controls the placement of the children.
  ScatterDelegate get delegate => _delegate;
  ScatterDelegate _delegate;
  set delegate(ScatterDelegate value) {
    assert(value != null);
    if (_delegate == value) {
      return;
    }
    if (value.runtimeType != _delegate.runtimeType ||
        value.shouldRelayout(_delegate)) {
      markNeedsLayout();
    }
    _delegate = value;
  }

  // Determine how the children will be placed.
  Alignment get alignment => _alignment;
  Alignment _alignment;
  set alignment(Alignment value) {
    assert(value != null);
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ScatterParentData)
      child.parentData = ScatterParentData();
  }

  @override
  void performLayout() {
    _hasVisualOverflow = false;
    if (childCount == 0) {
      size = constraints.smallest;
      assert(size.isFinite);
      return;
    }

    Rect bounds = Rect.zero;

    final Size maxSize = constraints.biggest;
    delegate._setAvailableSize(maxSize);

    RenderBox child = firstChild;
    int index = 0;
    while (child != null) {
      final ScatterParentData childParentData = child.parentData;
      childParentData.index = index;

      child.layout(constraints, parentUsesSize: true);

      final Size childSize = child.size;
      childParentData.width = childSize.width;
      childParentData.height = childSize.height;

      // Place the child following the placement strategy
      // until it does not overlap any previous child.
      int iteration = -1;
      do {
        final position = delegate.getPositionForIteration(
          ++iteration,
          childSize,
        );
        childParentData.offset = position - alignment.alongSize(childSize);
      } while (_overlaps(childParentData));

      bounds = bounds.expandToInclude(childParentData.rect);

      child = childParentData.nextSibling;
      index++;
    }

    size = constraints
        .tighten(width: bounds.width, height: bounds.height)
        .smallest;

    _hasVisualOverflow =
        size.width < bounds.width || size.height < bounds.height;

    // Center the scatter.
    Offset boundsCenter = bounds.center;
    Offset scatterCenter = size.center(Offset.zero);
    Offset translation = scatterCenter - boundsCenter;

    // Move the whole scatter to the center.
    child = firstChild;
    while (child != null) {
      final ScatterParentData childParentData = child.parentData;
      childParentData.offset += translation;
      child = childParentData.nextSibling;
    }
  }

  bool _overlaps(ScatterParentData data) {
    final Rect rect = data.rect;

    RenderBox child = data.previousSibling;

    while (child != null) {
      ScatterParentData childParentData = child.parentData;
      if (rect.overlaps(childParentData.rect)) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow)
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    else
      defaultPaint(context, offset);
  }
}
