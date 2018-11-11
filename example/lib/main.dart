import 'package:example/flutter_hashtags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

void main() => runApp(MyApp());

class TextApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.center,
        child: Scatter(
          alignment: Alignment.center,
          delegate: AlignScatterDelegate(alignment: Alignment.topCenter),
          children: List.generate(
            4,
            (i) => Container(
                  width: (i + 1) * 20.0,
                  height: (i + 1) * 20.0,
                  key: ValueKey(i),
                  color: i.isEven ? Colors.blue : Colors.orange,
                  child: Text('$i'),
                ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Page(),
    );
  }
}

class DiagonalScatterDelegate extends ScatterDelegate {
  @override
  Offset getPositionForIteration(int iteration, ScatterContext context) {
    return context.bounds.bottomRight;
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    for (var i = 0; i < kFlutterHashtags.length; i++) {
      widgets.add(ScatterItem(kFlutterHashtags[i], i));
    }

    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;

    return Scaffold(
      body: Center(
        child: FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: ArchimedeanSpiralScatterDelegate(ratio: 16.0 / 9.0),
            children: widgets,
          ),
        ),
      ),
    );
  }
}

class ScatterItem extends StatelessWidget {
  ScatterItem(this.hashtag, this.index);
  final FlutterHashtag hashtag;
  final int index;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.body1.copyWith(
          fontSize: hashtag.size.toDouble(),
          color: hashtag.color,
        );

    // return Container(
    //   height: 20.0,
    //   width: 20.0,
    //   decoration: BoxDecoration(shape: BoxShape.circle, color: hashtag.color),
    //   child: Center(child: Text('$index')),
    // );

    return RotatedBox(
      quarterTurns: hashtag.rotated ? 1 : 0,
      child: Text(
        hashtag.hashtag,
        style: style,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  AnimationController startOffset;

  void initState() {
    super.initState();
    startOffset = AnimationController.unbounded(
      vsync: this,
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: Flow(
            delegate: TestFlowDelegate(startOffset: startOffset),
            children: <Widget>[
              buildBox(0),
              buildBox(1),
              buildBox(2),
              buildBox(3),
              buildBox(4),
              buildBox(5),
              buildBox(6),
            ]));
  }

  Widget buildBox(int i) {
    return MyBox(i);
  }
}

class MyBox extends StatefulWidget {
  MyBox(this.i);
  final int i;

  @override
  _MyBoxState createState() => new _MyBoxState();
}

class _MyBoxState extends State<MyBox> {
  Color color;

  void initState() {
    super.initState();
    color = widget.i.isEven ? const Color(0xFF0000FF) : Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        width: 100.0,
        height: 100.0,
        child: GestureDetector(
            onTap: () => setState(() {
                  color = Colors.green;
                }),
            child: Text('${widget.i}', textDirection: TextDirection.ltr)));
  }
}

class TestFlowDelegate extends FlowDelegate {
  TestFlowDelegate({this.startOffset}) : super(repaint: startOffset);

  final Animation<double> startOffset;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = startOffset.value;
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, transform: Matrix4.translationValues(0.0, dy, 0.0));
      dy += 2 * context.getChildSize(i).height;
    }
  }

  @override
  bool shouldRepaint(TestFlowDelegate oldDelegate) =>
      startOffset == oldDelegate.startOffset;
}

class OpacityFlowDelegate extends FlowDelegate {
  OpacityFlowDelegate(this.opacity);

  double opacity;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(OpacityFlowDelegate oldDelegate) =>
      opacity != oldDelegate.opacity;
}
