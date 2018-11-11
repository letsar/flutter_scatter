import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

class CircleExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int count = 20;
    List<Widget> widgets = <Widget>[];
    for (var i = 0; i < count; i++) {
      widgets.add(ScatterItem(i));
    }

    return Center(
      child: Scatter(
        delegate: EllipseScatterDelegate(
          a: 185.0,
          b: 185.0,
          step: 1.0 / count,
        ),
        children: widgets,
      ),
    );
  }
}

class ScatterItem extends StatelessWidget {
  ScatterItem(this.index);
  final int index;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.body1.copyWith(
          color: Colors.white,
        );
    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index.isEven ? Colors.red : Colors.pink),
      child: Center(
          child: Text(
        '$index',
        style: style,
      )),
    );
  }
}
