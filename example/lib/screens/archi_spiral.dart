import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

class ArchiSpiralExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int count = 50;
    List<Widget> widgets = <Widget>[];
    for (var i = 0; i < count; i++) {
      widgets.add(ScatterItem(i));
    }

    return Center(
      child: FittedBox(
        child: Scatter(
          delegate: ArchimedeanSpiralScatterDelegate(
            a: 35.0,
            step: 0.01,
          ),
          children: widgets,
        ),
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
    return GestureDetector(
      onTap: () => Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('$index'),
          )),
      child: Container(
        height: 35.0,
        width: 35.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index.isEven ? Colors.red : Colors.pink),
        child: Center(
            child: Text(
          '$index',
          style: style,
        )),
      ),
    );
  }
}
