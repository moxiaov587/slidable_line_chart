import 'package:flutter/material.dart';

import 'package:flutter_line_chart/flutter_line_chart.dart';

void main() {
  runApp(const MyApp());
}

enum ViewType {
  // all,
  left,
  right,
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<View<ViewType>> allViews = [
    View<ViewType>(id: 1, type: ViewType.left, initialValue: -12),
    View<ViewType>(id: 2, type: ViewType.left, initialValue: -14),
    View<ViewType>(id: 3, type: ViewType.left, initialValue: -16),
    View<ViewType>(id: 4, type: ViewType.left, initialValue: -18),
    View<ViewType>(id: 5, type: ViewType.left, initialValue: -20),
    View<ViewType>(id: 6, type: ViewType.left, initialValue: -22),
  ];

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
                child: FlutterLineChart(
                  viewTypeValues: ViewType.values,
                  // canDragViewType: ViewType.right,
                  allViews: allViews,
                  xAxis: const ['500', '1k', '2k', '4k', '6k', '8k'],
                  yAxisStep: 1,
                  yAxisMaxValue: -12,
                  yAxisMinValue: -24,
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
                  onChangeAllViewsCallback:
                      (List<View<ViewType>> currentViews) {
                    setState(() {
                      allViews = currentViews;
                    });
                  },
                  onChangeEndAllViewsCallback:
                      (List<View<ViewType>> currentViews) {
                    setState(() {
                      allViews = currentViews;
                    });
                  },
                ),
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
            // setState(() {
            //   if (layer.currentViewsValue == null) {
            //     result = '当前没有有效的可拖动[View]';
            //   } else {
            //     result = layer.currentViewsValue!.join(', ');
            //   }
            // });

            // layer.canDragViewType = ViewType.right;

            // layer.changeViewsValueByViewType(
            //   ViewType.left,
            //   values: [
            //     50,
            //     60,
            //     70,
            //     80,
            //     90,
            //     100,
            //   ],
            // );
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}
