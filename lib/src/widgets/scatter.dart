import 'package:flutter/widgets.dart';
import 'package:flutter_scatter/src/rendering/scatter.dart';

/// A widget that positions its children with a [ScatterDelegate]
/// without overlapping them.
///
/// This class is useful when you want to create a cloud of words.
class Scatter extends MultiChildRenderObjectWidget {
  Scatter({
    Key key,
    ScatterDelegate delegate,
    this.overflow = Overflow.clip,
    this.maxChildIteration = 10000,
    this.fillGaps = false,
    List<Widget> children = const <Widget>[],
  })  : delegate = delegate ?? ArchimedeanSpiralScatterDelegate(),
        super(key: key, children: children);

  /// The delegate that controls the layout of the [Scatter].
  final ScatterDelegate delegate;

  /// Whether overflowing children should be clipped. See [Overflow].
  ///
  /// Some children in a scatter might overflow its box. When this flag is set to
  /// [Overflow.clip], children cannot paint outside of the stack's box.
  final Overflow overflow;

  /// The maximum of iterations we can do for one child.
  ///
  /// When it's impossible to place another child, a FlutterError
  /// is thrown when this number of iterations for one child is reached.
  final int maxChildIteration;

  /// Indicates whether gaps should be filled if possible.
  /// Setting this value to `true` is more expansive.
  ///
  /// If `true` the [maxChildIteration] will be multiplied by
  /// the index of the current child.
  ///
  /// Defaults to false.
  final bool fillGaps;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScatter(
      delegate: delegate,
      overflow: overflow,
      maxChildIteration: maxChildIteration,
      fillGaps: fillGaps,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderScatter renderObject) {
    renderObject
      ..delegate = delegate
      ..overflow = overflow
      ..maxChildIteration = maxChildIteration
      ..fillGaps = fillGaps;
  }
}
