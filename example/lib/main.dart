import 'package:example/screens/align.dart';
import 'package:example/screens/archi_spiral.dart';
import 'package:example/screens/circle.dart';
import 'package:example/screens/word_cloud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

void main() => runApp(ScatterApp());

class ScatterHomeTileData {
  ScatterHomeTileData({
    @required this.route,
    @required this.builder,
    @required this.text,
    @required this.diameter,
    @required this.color,
  });
  final double diameter;
  final Color color;
  final String text;
  final String route;
  final WidgetBuilder builder;
}

final List<ScatterHomeTileData> _tiles = <ScatterHomeTileData>[
  ScatterHomeTileData(
    route: 'word_cloud',
    text: 'Word Cloud',
    builder: (_) => WordCloudExample(),
    diameter: 100.0,
    color: Colors.green,
  ),
  ScatterHomeTileData(
    route: 'circle',
    text: 'Circle',
    builder: (_) => CircleExample(),
    diameter: 50.0,
    color: Colors.blue,
  ),
  ScatterHomeTileData(
    route: 'align',
    text: 'Align',
    builder: (_) => AlignExample(),
    diameter: 70.0,
    color: Colors.red,
  ),
  ScatterHomeTileData(
    route: 'spiral',
    text: 'Spiral',
    builder: (_) => ArchiSpiralExample(),
    diameter: 60.0,
    color: Colors.orange,
  ),
];

class ScatterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scatter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScatterHomePage(),
      routes: Map.fromEntries(
        _tiles.map((t) => MapEntry<String, WidgetBuilder>(
            t.route,
            (_) => SimpleScaffold(
                  title: t.text,
                  child: Builder(builder: t.builder),
                ))),
      ),
    );
  }
}

class ScatterHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scatter Demo')),
      body: Center(
        child: Scatter(
          delegate: FermatSpiralScatterDelegate(),
          children: _tiles.map((t) => ScatterHomeTile(t)).toList(),
        ),
      ),
    );
  }
}

class ScatterHomeTile extends StatelessWidget {
  ScatterHomeTile(
    this.data,
  );
  final ScatterHomeTileData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color,
      borderRadius: BorderRadius.circular(data.diameter / 2.0),
      child: InkWell(
        radius: data.diameter / 2.0,
        customBorder: CircleBorder(),
        onTap: () => Navigator.of(context).pushNamed(data.route),
        child: Container(
          width: data.diameter,
          height: data.diameter,
          child: Center(
            child: Text(
              data.text,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

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

class SimpleScaffold extends StatelessWidget {
  const SimpleScaffold({
    Key key,
    this.title,
    this.child,
  }) : super(key: key);

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: child,
    );
  }
}
