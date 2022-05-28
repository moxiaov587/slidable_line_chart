import 'package:flutter/material.dart';
import 'package:flutter_line_chart/flutter_line_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Layer layer = Layer(
    views: [
      // View(initialValue: 1),
      // View(initialValue: 2),
      // View(initialValue: 3),
      // View(initialValue: 4),
      // View(initialValue: 5),
      // View(initialValue: 6),

      ///
      View(initialValue: 10),
      View(initialValue: 20),
      View(initialValue: 30),
      View(initialValue: 40),
      View(initialValue: 50),
      View(initialValue: 60),
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
              result = layer.currentViewsValue.join(', ');
            });
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}
