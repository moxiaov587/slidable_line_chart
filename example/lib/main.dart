import 'package:flutter/material.dart';
import 'package:flutter_line_chart/flutter_line_chart.dart';

void main() {
  runApp(const MyApp());
}

enum ViewType {
  all,
  left,
  right,
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Layer<ViewType> layer = Layer(
    viewTypeValues: ViewType.values,
    allViews: [
      // View<ViewType>(type: ViewType.left, initialValue: 1),
      // View<ViewType>(type: ViewType.left, initialValue: 2),
      // View<ViewType>(type: ViewType.left, initialValue: 3),
      // View<ViewType>(type: ViewType.left, initialValue: 4),
      // View<ViewType>(type: ViewType.left, initialValue: 5),
      // View<ViewType>(type: ViewType.left, initialValue: 6),

      ///
      // View<ViewType>(type: ViewType.all, initialValue: 30),
      // View<ViewType>(type: ViewType.all, initialValue: 50),
      // View<ViewType>(type: ViewType.all, initialValue: 70),
      // View<ViewType>(type: ViewType.all, initialValue: 90),
      // View<ViewType>(type: ViewType.all, initialValue: 110),
      // View<ViewType>(type: ViewType.all, initialValue: 10),

      View<ViewType>(type: ViewType.left, initialValue: 10),
      View<ViewType>(type: ViewType.left, initialValue: 20),
      View<ViewType>(type: ViewType.left, initialValue: 30),
      View<ViewType>(type: ViewType.left, initialValue: 40),
      View<ViewType>(type: ViewType.left, initialValue: 50),
      View<ViewType>(type: ViewType.left, initialValue: 60),

      View<ViewType>(type: ViewType.right, initialValue: 60),
      View<ViewType>(type: ViewType.right, initialValue: 50),
      View<ViewType>(type: ViewType.right, initialValue: 40),
      View<ViewType>(type: ViewType.right, initialValue: 30),
      View<ViewType>(type: ViewType.right, initialValue: 20),
      View<ViewType>(type: ViewType.right, initialValue: 10),
    ],
    xAxis: ['500', '1k', '2k', '4', '6k', '8k'],
    yAxisStep: 5,
    yAxisMaxValue: 120,
    yAxisMinValue: 0,
    drawCheckOrClose: (double value) {
      return value >= 30;
    },
    showTapArea: true,
    enforceStepOffset: true,
    viewStyles: {
      ViewType.left: ViewStyle(
        axisPointColor: Colors.red,
        linkLineColor: Colors.redAccent,
        fillAreaColor: Colors.red.withOpacity(.3),
      )
    },
  );

  String? result;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterLineChart example app'),
        ),
        body: Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.only(
                left: 30,
                right: 10,
              ),
              child: Center(
                child: FlutterLineChart(layer: layer),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Text(
                result ?? '点击按钮获取当前数据',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (layer.currentViewsValue == null) {
                result = '当前没有有效的可拖动[View]';
              } else {
                result = layer.currentViewsValue!.join(', ');
              }
            });
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}
