import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

const double _2pi = math.pi * 2;

/// A context in which a [ScatterDelegate] positions
/// the [RenderScatter] children.
///
/// See also:
///
///  * [ScatterDelegate]
///  * [RenderScatter]
class ScatterContext {
  ScatterContext._(
    this.childSize,
    this.previousChldRect,
    this.bounds,
    this.alignment,
  );
  final Size childSize;
  final Rect previousChldRect;
  final Rect bounds;
  final Alignment alignment;
}

/// A delegate that controls the layout of a [Scatter].
abstract class ScatterDelegate {
  /// Creates the delegate used by [RenderScatter] to
  /// place its children.
  ScatterDelegate({
    this.ratio,
  });

  /// The ratio used to place the children.
  ///
  /// For example if ratio is 16.0/9.0,
  /// children must be placed in a rectangle box
  /// with dimensions width/height respecting 16.0/9.0.
  final double ratio;

  double _ratioX;

  /// The ratio used for the x-axis points.
  double get ratioX => _ratioX;

  double _ratioY;

  /// The ratio used for the y-axis points.
  double get ratioY => _ratioY;

  Size _availableSize;

  /// The available size to place children.
  Size get availableSize => _availableSize;
  void _setAvailableSize(Size value) {
    _availableSize = value;
    final double ratio =
        this.ratio ?? (value.isFinite ? value.width / value.height : 1.0);
    _ratioX = ratio >= 1 ? ratio : 1.0;
    _ratioY = ratio <= 1 ? ratio : 1.0;
  }

  /// Returns the child offset for the given iteration.
  ///
  /// For a given iteration, the position should be unique.
  Offset getChildOffsetForIteration(int iteration, ScatterContext context) {
    final Offset position = getPositionForIteration(iteration, context);
    return getChildOffset(position, context);
  }

  /// Returns an offset for the specified iteration.
  ///
  /// For a given iteration, the offset should be unique.
  @protected
  Offset getPositionForIteration(int iteration, ScatterContext context);

  /// Returns the child offset for the given position.
  @protected
  Offset getChildOffset(Offset position, ScatterContext context) {
    return position - context.alignment.alongSize(context.childSize);
  }

  /// Override this method to return true when the children need to be laid out.
  /// This should compare the fields of the current delegate and the given
  /// oldDelegate and return true if the fields are such that the layout would
  /// be different.
  @mustCallSuper
  bool shouldRelayout(covariant ScatterDelegate oldDelegate) {
    return oldDelegate.ratio != ratio;
  }
}

/// A [ScatterDelegate] that places children in a spiral.
///
/// See:
/// * [ArchimedeanSpiralScatterDelegate] which represents an archimedean spiral.
/// * [FermatSpiralScatterDelegate] which represents a special case of archimedean spiral.
/// * [LogarithmicSpiralScatterDelegate] which represents a logarithmic spiral.
abstract class SpiralScatterDelegate extends ScatterDelegate {
  /// Create a spiral where for each increment the angle is increased
  /// by [step] * 2π radians and with the given [rotation].
  ///
  /// For example if [step] is 0.25, the angle will be increased
  /// by π/2 radians.
  /// The [step] is a value between 0.0 and 1.0.
  ///
  /// The [rotation] is a value between 0.0 and 1.0.
  /// A [rotation] of 0.5 represents a rotation of π/2 radians.
  SpiralScatterDelegate({
    double ratio,
    double step = 0.01,
    double rotation = 0.0,
  })  : assert(step != null && step >= 0.0 && step <= 1.0),
        assert(rotation != null && rotation >= 0.0 && rotation <= 1.0),
        _stepRadians = step * _2pi,
        _rotationRadians = rotation * _2pi,
        super(ratio: ratio);

  final double _stepRadians;

  final double _rotationRadians;

  Offset getPositionForIteration(
    int iteration,
    ScatterContext context,
  ) {
    final double angle = iteration * _stepRadians;
    final double radius = computeRadius(angle);
    final double x = ratioX * radius * math.cos(angle + _rotationRadians);
    final double y = ratioY * radius * math.sin(angle + _rotationRadians);
    return Offset(x, y);
  }

  /// All spirals are a function of the angle: r=f(θ).
  double computeRadius(double angle);

  bool shouldRelayout(covariant SpiralScatterDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate._stepRadians != _stepRadians ||
        oldDelegate._rotationRadians != _rotationRadians;
  }
}

/// A [ScatterDelegate] that places children in an archimedean spiral.
/// See: https://en.wikipedia.org/wiki/Archimedean_spiral.
class ArchimedeanSpiralScatterDelegate extends SpiralScatterDelegate {
  /// Creates an archimedean spiral [ScatterDelegate].
  ///
  /// An archimedean spiral has this polar equation: **r=a+bθ**
  ArchimedeanSpiralScatterDelegate({
    double ratio,
    this.a = 10.0,
    this.b = 10.0,
    double step = 0.01,
    double rotation = 0.0,
  }) : super(
          ratio: ratio,
          step: step,
          rotation: rotation,
        );

  /// The initial radius of the spiral.
  ///
  /// This is the **a** parameter in the equation **r=a+bθ**.
  final double a;

  /// The distance between successive turns of the spiral.
  ///
  /// This is the **b** parameter in the equation **r=a+bθ**.
  final double b;

  double computeRadius(double angle) => a + b * angle;

  bool shouldRelayout(covariant ArchimedeanSpiralScatterDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.a != a ||
        oldDelegate.b != b;
  }
}

/// A [ScatterDelegate] that places children in a Fermat spiral.
/// See: https://en.wikipedia.org/wiki/Fermat%27s_spiral.
class FermatSpiralScatterDelegate extends ArchimedeanSpiralScatterDelegate {
  static const double goldenAngle = 0.381966;

  /// Creates a Fermat spiral [ScatterDelegate].
  ///
  /// A Fermat spiral has this polar equation: **r=a+b√θ**
  FermatSpiralScatterDelegate({
    double ratio,
    double a = 1.0,
    double b = 15.0,
    double step = 0.47,
    double rotation = 0.0,
  }) : super(
          ratio: ratio,
          step: step,
          rotation: rotation,
          a: a,
          b: b,
        );

  double computeRadius(double angle) => a + b * math.sqrt(angle);
}

/// A [ScatterDelegate] that places children in a Logarithmic spiral.
/// See: https://en.wikipedia.org/wiki/Logarithmic_spiral.
class LogarithmicSpiralScatterDelegate extends SpiralScatterDelegate {
  /// Creates a logarithmic spiral [ScatterDelegate].
  ///
  /// A logarithmic spiral has this polar equation: **r=ae^bθ**
  LogarithmicSpiralScatterDelegate({
    double ratio,
    this.a = 1.0,
    this.b = 0.3063489,
    double step = 0.01,
    double rotation = 0.0,
  }) : super(
          ratio: ratio,
          step: step,
          rotation: rotation,
        );

  /// The initial radius of the spiral.
  ///
  /// This is the **a** parameter in the equation **r=ae^bθ**.
  final double a;

  /// The distance between successive turns of the spiral.
  ///
  /// This is the **b** parameter in the equation **r=ae^bθ**.
  final double b;

  double computeRadius(double angle) => a * math.exp(b * angle);
}

/// A [ScatterDelegate] that aligns a child with its predecessor.
class AlignScatterDelegate extends ScatterDelegate {
  /// Creates a delegate where a child is aligned with its predecessor.
  ///
  /// The [alignment] must not be null, and must be on the side.
  AlignScatterDelegate({
    this.alignment = Alignment.bottomRight,
  })  : assert(alignment != null &&
            (alignment.x.abs() == 1 || alignment.y.abs() == 1)),
        _oppositeAlignment = -alignment;

  /// How to align a child with the previous one.
  final Alignment alignment;

  final Alignment _oppositeAlignment;

  @override
  Offset getPositionForIteration(int iteration, ScatterContext context) {
    return alignment.withinRect(context.previousChldRect);
  }

  /// Returns the child offset for the given position.
  @protected
  Offset getChildOffset(Offset position, ScatterContext context) {
    return position - _oppositeAlignment.alongSize(context.childSize);
  }
}

/// A [ScatterDelegate] that places children on an ellipse.
class EllipseScatterDelegate extends ScatterDelegate {
  /// Creates a delegate where children of a [RenderScatter]
  /// are placed on an ellipse.
  ///
  /// The parametric representation of an ellipse is
  /// **(x,y)=(a cos θ, b sin θ)**
  ///
  /// The arguments cannot be null.
  /// The arguments [a] and [b] must be positive and [step] cannot be zero.
  EllipseScatterDelegate({
    @required this.a,
    @required this.b,
    double step = 0.01,
    double start = 0.0,
  })  : assert(a != null && a > 0),
        assert(b != null && b > 0),
        assert(step != null && step != 0),
        assert(start != null),
        _stepRadians = step * _2pi,
        _startRadians = start * _2pi;

  /// Semi x-axis.
  final double a;

  /// Semi y-axis.
  final double b;

  final double _stepRadians;
  final double _startRadians;

  @override
  Offset getPositionForIteration(int iteration, ScatterContext context) {
    final double angle = iteration * _stepRadians;
    final double x = a * math.cos(angle + _startRadians);
    final double y = b * math.sin(angle + _startRadians);
    return Offset(x, y);
  }
}

/// Parent data used by [RenderScatter] and its subclasses.
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

/// Implements the scatter layout algorithm.
///
/// In a scatter layout, the children cannot overlap.
/// They are placed with a delegate that is called until
/// we find a position where the current child does not overlap
/// previous children.
///
/// To check if a child overlap another, we simply check
/// if the rectangles englobing these objects are overlapping.
class RenderScatter extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ScatterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ScatterParentData> {
  /// Creates a scatter render object.
  RenderScatter({
    @required ScatterDelegate delegate,
    Alignment alignment = Alignment.topLeft,
    List<RenderBox> children,
    Overflow overflow = Overflow.clip,
    int maxChildIteration = 10000,
    bool fillGaps = false,
  })  : assert(delegate != null),
        assert(alignment != null),
        assert(maxChildIteration != null && maxChildIteration > 0),
        _delegate = delegate,
        _alignment = alignment,
        _overflow = overflow,
        _maxChildIteration = maxChildIteration,
        _fillGaps = fillGaps {
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

  /// Whether overflowing children should be clipped. See [Overflow].
  ///
  /// Some children in a stack might overflow its box. When this flag is set to
  /// [Overflow.clip], children cannot paint outside of the stack's box.
  Overflow get overflow => _overflow;
  Overflow _overflow;
  set overflow(Overflow value) {
    assert(value != null);
    if (_overflow != value) {
      _overflow = value;
      markNeedsPaint();
    }
  }

  /// The maximum of iterations we can do for one child.
  ///
  /// When it's impossible to place another child, a FlutterError
  /// is thrown when this number of iterations for one child is reached.
  int get maxChildIteration => _maxChildIteration;
  int _maxChildIteration;
  set maxChildIteration(int value) {
    assert(value != null);
    if (_maxChildIteration != value) {
      _maxChildIteration = value;
      markNeedsPaint();
    }
  }

  /// Indicates whether gaps should be filled if possible.
  /// Setting this value to `true` is more expansive.
  ///
  /// If `true` the [maxChildIteration] will be multiplied by
  /// the index of the current child.
  ///
  /// Defaults to false.
  bool get fillGaps => _fillGaps;
  bool _fillGaps;
  set fillGaps(bool value) {
    assert(value != null);
    if (_fillGaps != value) {
      _fillGaps = value;
      markNeedsPaint();
    }
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
    size = Size.zero;
    delegate._setAvailableSize(maxSize);

    RenderBox child = firstChild;
    int index = 0;
    Rect previousChildRect = Rect.zero;
    int iteration = -1;
    while (child != null) {
      if (_fillGaps) {
        iteration = -1;
      }

      final ScatterParentData childParentData = child.parentData;
      childParentData.index = index;

      child.layout(constraints, parentUsesSize: true);

      final Size childSize = child.size;
      childParentData.width = childSize.width;
      childParentData.height = childSize.height;

      // Place the child following the placement strategy
      // until it does not overlap any previous child.
      final int max =
          _fillGaps ? _maxChildIteration * (index + 1) : _maxChildIteration;
      final int startIteration = iteration;
      do {
        assert(() {
          if (iteration - startIteration >= max) {
            throw FlutterError('Too much iterations for one child.\n'
                'It may be impossible to place another child with this delegate '
                'or consider to increase to maxChildIteration');
          }
          return true;
        }());
        final childOffset = delegate.getChildOffsetForIteration(
          ++iteration,
          ScatterContext._(
            childSize,
            previousChildRect,
            bounds,
            alignment,
          ),
        );
        childParentData.offset = childOffset;
      } while (_overlaps(childParentData));

      previousChildRect = childParentData.rect;
      bounds = bounds.expandToInclude(previousChildRect);

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
    if (_hasVisualOverflow && _overflow == Overflow.clip)
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
