import 'package:flutter/material.dart';

import 'package:slidable_line_chart/slidable_line_chart.dart';

void main() {
  runApp(const MyApp());
}

enum CoordinateType {
  left,
  right,
}

class TestData {
  TestData({
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    required this.yAxisDivisions,
  }) : data = List<int>.generate(12, (index) => index)
            .fold<List<Coordinate<CoordinateType>>>([], (previousValue, index) {
          late Coordinate<CoordinateType> coordinate;
          if (previousValue.isEmpty) {
            coordinate = Coordinate<CoordinateType>(
              id: index,
              type: CoordinateType.left,
              initialValue: yAxisMinValue.toDouble(),
            );
          } else {
            coordinate = Coordinate<CoordinateType>(
              id: index,
              type: index >= 6 ? CoordinateType.right : CoordinateType.left,
              initialValue: previousValue.last.initialValue + yAxisDivisions,
            );
          }

          return [...previousValue, coordinate];
        });

  final List<Coordinate<CoordinateType>> data;
  final int yAxisMaxValue;
  final int yAxisMinValue;
  final int yAxisDivisions;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<TestData> testData = [
    TestData(
      yAxisMaxValue: -12,
      yAxisMinValue: -24,
      yAxisDivisions: 1,
    ),
    TestData(
      yAxisMaxValue: 0,
      yAxisMinValue: -12,
      yAxisDivisions: 1,
    ),
    TestData(
      yAxisMaxValue: 120,
      yAxisMinValue: 0,
      yAxisDivisions: 10,
    ),
    TestData(
      yAxisMaxValue: 120,
      yAxisMinValue: 20,
      yAxisDivisions: 5,
    ),
  ];

  int index = 3;

  List<Coordinate<CoordinateType>> get allCoordinates => testData[index].data;

  int get yAxisMaxValue => testData[index].yAxisMaxValue;
  int get yAxisMinValue => testData[index].yAxisMinValue;
  int get yAxisDivisions => testData[index].yAxisDivisions;

  CoordinateType? canDragCoordinateType = CoordinateType.left;

  bool reversedYAxis = false;

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
                child: SlidableLineChart(
                  canDragCoordinateType: canDragCoordinateType,
                  allCoordinates: allCoordinates,
                  reversedYAxis: reversedYAxis,
                  xAxis: const <String>['500', '1k', '2k', '4k', '6k', '8k'],
                  yAxisDivisions: yAxisDivisions,
                  yAxisMaxValue: yAxisMaxValue,
                  yAxisMinValue: yAxisMinValue,
                  drawCheckOrClose: (double value) {
                    return value >= 30;
                  },
                  showTapArea: true,
                  enforceStepOffset: true,
                  coordinateStyles: {
                    CoordinateType.left: CoordinateStyle(
                      coordinatePointColor: Colors.red,
                      linkLineColor: Colors.redAccent,
                      fillAreaColor: Colors.red.withOpacity(.3),
                    )
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 50,
                bottom: 30,
              ),
              child: Text(
                result ?? '点击按钮获取当前数据',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    switch (canDragCoordinateType) {
                      case null:
                        setState(() {
                          canDragCoordinateType = CoordinateType.left;
                        });
                        break;
                      case CoordinateType.left:
                        setState(() {
                          canDragCoordinateType = CoordinateType.right;
                        });
                        break;
                      case CoordinateType.right:
                        setState(() {
                          canDragCoordinateType = null;
                        });
                        break;
                    }
                  },
                  child: Text(
                    '切换可拖动类型',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => reversedYAxis = !reversedYAxis);
                  },
                  child: Text(
                    '反向Y轴',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    int data = index + 1;

                    data = data == testData.length ? 1 : data;
                    setState(() => index = data);
                  },
                  child: Text(
                    '切换数据源',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (canDragCoordinateType == null) {
                      setState(() => result = '当前没有可拖动的Coordinate');
                    } else {
                      setState(() => result = testData[index]
                          .data
                          .where((coordinate) =>
                              coordinate.type == canDragCoordinateType)
                          .map((coordinate) => coordinate.currentValue)
                          .join(','));
                    }
                  },
                  child: Text(
                    '获取当前数据',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
