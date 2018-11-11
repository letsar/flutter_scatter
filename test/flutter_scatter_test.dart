import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

class SamePositionScatterDelegate extends ScatterDelegate {
  @override
  Offset getPositionForIteration(int iteration, ScatterContext context) {
    return Offset.zero;
  }
}

void main() {
  group('AlignScatterDelegate', () {
    testWidgets('bottomRight', (WidgetTester tester) async {
      final int count = 4;
      final double size = 20.0;
      await tester.pumpWidget(
        Align(
          alignment: Alignment.topLeft,
          child: Scatter(
            delegate: AlignScatterDelegate(alignment: Alignment.bottomRight),
            children: List.generate(
              count,
              (i) => Container(
                    width: size,
                    height: size,
                    key: ValueKey(i),
                    color: Colors.blue,
                  ),
            ),
          ),
        ),
      );

      await tester.pump();

      for (var i = 0; i < count; i++) {
        final key = ValueKey(i);
        expect(find.byKey(key), findsOneWidget);
        Offset topLeft = tester.getTopLeft(find.byKey(key));
        expect(topLeft, Offset(i * size, i * size));
      }
    });

    testWidgets('topLeft', (WidgetTester tester) async {
      final int count = 4;
      final double size = 20.0;
      await tester.pumpWidget(
        Align(
          alignment: Alignment.topLeft,
          child: Scatter(
            delegate: AlignScatterDelegate(alignment: Alignment.topLeft),
            children: List.generate(
              count,
              (i) => Container(
                    width: size,
                    height: size,
                    key: ValueKey(i),
                    color: Colors.blue,
                  ),
            ),
          ),
        ),
      );

      await tester.pump();

      for (var i = 0; i < count; i++) {
        final key = ValueKey(i);
        expect(find.byKey(key), findsOneWidget);
        Offset topLeft = tester.getTopLeft(find.byKey(key));
        expect(topLeft, Offset((count - 1 - i) * size, (count - 1 - i) * size));
      }
    });
  });

  testWidgets('FlutterError is maxChildIteration reached',
      (WidgetTester tester) async {
    final int count = 2;
    final double size = 20.0;
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Scatter(
          maxChildIteration: 2,
          delegate: SamePositionScatterDelegate(),
          children: List.generate(
            count,
            (i) => Container(
                  width: size,
                  height: size,
                  key: ValueKey(i),
                  color: Colors.blue,
                ),
          ),
        ),
      ),
    );

    //var t = tester.takeException();
    await tester.pump();
    expect(tester.takeException(), isFlutterError);
  });
}
