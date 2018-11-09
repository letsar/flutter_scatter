import 'package:flutter/widgets.dart';
import 'package:flutter_scatter/src/rendering/scatter.dart';

class Scatter extends MultiChildRenderObjectWidget {
  Scatter({
    Key key,
    ScatterDelegate delegate,
    this.alignment = Alignment.topLeft,
    List<Widget> children = const <Widget>[],
  })  : delegate = delegate ?? ArchimedeanSpiralScatterDelegate(),
        super(key: key, children: children);

  /// The delegate that controls the layout of the [Scatter].
  final ScatterDelegate delegate;

  /// Determine how the children will be placed on
  /// the [ScatterDelegate.getPositionForIteration] offset.
  ///
  /// For example if [alignement] is [Alignment.center], all
  /// offsets given by [ScatterDelegate.getPositionForIteration]
  /// will be at center of a child.
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScatter(
      delegate: delegate,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderScatter renderObject) {
    renderObject
      ..delegate = delegate
      ..alignment = alignment;
  }
}
