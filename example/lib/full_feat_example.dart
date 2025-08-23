import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slidable_line_chart/slidable_line_chart.dart';

enum _CoordinateType {
  left,
  right,
}

class TestData {
  TestData({
    required this.min,
    required this.max,
    required this.divisions,
  }) : data = [
          CoordinatesOptions(
            _CoordinateType.left,
            values: List.generate(
              6,
              (index) => (Random().nextInt(max - min) + min).toDouble(),
            ),
          ),
          CoordinatesOptions(
            _CoordinateType.right,
            values: List.generate(
              6,
              (index) => (Random().nextInt(max - min) + min).toDouble(),
            ),
          ),
        ];

  List<CoordinatesOptions<_CoordinateType>> data;
  final int min;
  final int max;
  final int divisions;
}

const List<double?> slidePrecisionList = [null, 1.0, 0.1, 0.01];

class FullFeatExample extends StatefulWidget {
  const FullFeatExample({Key? key, required this.switchThemeFn})
      : super(key: key);

  final VoidCallback switchThemeFn;

  @override
  State<FullFeatExample> createState() => _FullFeatExampleState();
}

class _FullFeatExampleState extends State<FullFeatExample> {
  final List<TestData> testData = [
    TestData(
      min: -37,
      max: 12,
      divisions: 3,
    ),
    TestData(
      min: -12,
      max: 1,
      divisions: 1,
    ),
    TestData(
      min: 0,
      max: 120,
      divisions: 10,
    ),
    TestData(
      min: 3,
      max: 21,
      divisions: 2,
    ),
  ];

  late final List<List<CoordinatesOptions<_CoordinateType>>> _backupTestData;

  int index = 0;

  int slidePrecisionIndex = 0;

  final GlobalKey<SlidableLineChartState<_CoordinateType>> _key =
      GlobalKey<SlidableLineChartState<_CoordinateType>>();

  SlidableLineChartState<_CoordinateType>? get _slidableLineChartState =>
      _key.currentState;

  List<CoordinatesOptions<_CoordinateType>> get coordinatesOptionsList =>
      testData[index].data;

  int get min => testData[index].min;
  int get max => testData[index].max;
  int get divisions => testData[index].divisions;

  double? get slidePrecision => slidePrecisionList[slidePrecisionIndex];

  _CoordinateType? slidableCoordinateType = _CoordinateType.left;

  bool reversed = false;
  bool enableInitializationAnimation = true;
  double smooth = 0.0;

  String? result;

  @override
  void initState() {
    super.initState();

    _backupTestData =
        testData.map((e) => e.data.map((options) => options).toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full feat example'),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.only(
                left: 30,
                right: 10,
              ),
              child: Center(
                child: SlidableLineChartTheme(
                  data: SlidableLineChartThemeData<_CoordinateType>(
                    coordinatesStyleList: [
                      CoordinatesStyle<_CoordinateType>(
                        type: _CoordinateType.left,
                        pointColor: Theme.of(context).primaryColor,
                        lineColor: Theme.of(context).primaryColor,
                        fillAreaColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.5),
                      ),
                      CoordinatesStyle<_CoordinateType>(
                        type: _CoordinateType.right,
                        pointColor: Theme.of(context).colorScheme.error,
                        lineColor: Theme.of(context).colorScheme.error,
                        fillAreaColor: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.5),
                      ),
                    ],
                    showTapArea: true,
                    smooth: smooth,
                  ),
                  child: SlidableLineChart(
                    key: _key,
                    slidableCoordinateType: slidableCoordinateType,
                    coordinatesOptionsList: coordinatesOptionsList,
                    xAxis: const <String>['500', '1k', '2k', '4k', '6k', '8k'],
                    min: min,
                    max: max,
                    divisions: divisions,
                    slidePrecision: slidePrecision,
                    reversed: reversed,
                    // onlyRenderEvenAxisLabel: false,
                    enableInitializationAnimation:
                        enableInitializationAnimation,
                    // initializationAnimationDuration:
                    //     const Duration(milliseconds: 2000),
                    onDrawCheckOrClose: (double value) {
                      return value >= 30;
                    },
                    onChange:
                        (List<CoordinatesOptions<_CoordinateType>> options) {
                      setState(() => testData[index].data = options);
                    },
                    onChangeEnd:
                        (List<CoordinatesOptions<_CoordinateType>> options) {
                      setState(() => result = options
                          .singleWhere((options) =>
                              options.type == slidableCoordinateType)
                          .values
                          .join(','));
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 50,
                bottom: 30,
              ),
              child: Text(
                result ?? 'Echo data after sliding.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                bottom: 30,
              ),
              child: Text(
                'Current Slide Precision is $slidePrecision',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _CoordinateType? type;
                    switch (slidableCoordinateType) {
                      case null:
                        type = _CoordinateType.left;
                        break;
                      case _CoordinateType.left:
                        type = _CoordinateType.right;
                        break;
                      case _CoordinateType.right:
                        break;
                    }

                    setState(() {
                      result = null;
                      slidableCoordinateType = type;
                    });
                  },
                  child: Text(
                    'Toggle Slidable Type',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _slidableLineChartState?.resetAnimationController();

                    setState(() => reversed = !reversed);
                  },
                  child: Text(
                    'Reversed',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // _slidableLineChartState?.resetAnimationController();

                    setState(() => smooth = smooth == 0.0 ? 0.5 : 0.0);
                  },
                  child: Text(
                    'Smooth',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => enableInitializationAnimation =
                        !enableInitializationAnimation);
                  },
                  child: Text(
                    '${enableInitializationAnimation ? 'Disable' : 'Enable'} Animation',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    int data = slidePrecisionIndex + 1;
                    data = data == slidePrecisionList.length ? 0 : data;

                    setState(() => slidePrecisionIndex = data);
                  },
                  child: Text(
                    'Toggle Slide Precision',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    int data = index + 1;
                    data = data == testData.length ? 0 : data;

                    _slidableLineChartState?.resetAnimationController();

                    setState(() {
                      result = null;
                      index = data;
                    });
                  },
                  child: Text(
                    'Toggle Test Data',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _slidableLineChartState?.resetAnimationController(
                      resetAll: false,
                    );

                    setState(() => testData[index].data = [
                          slidableCoordinateType == _CoordinateType.left
                              ? _backupTestData[index][0]
                              : testData[index].data[0],
                          slidableCoordinateType != _CoordinateType.left
                              ? _backupTestData[index][1]
                              : testData[index].data[1],
                        ]);

                    if (slidableCoordinateType == null) {
                      setState(() => result = testData[index]
                          .data
                          .singleWhere((options) =>
                              options.type == slidableCoordinateType)
                          .values
                          .join(','));
                    }
                  },
                  child: Text(
                    'Reset',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (slidableCoordinateType == null) {
                      setState(() => result = 'No Slidable Coordinates');
                    } else {
                      setState(() => result = testData[index]
                          .data
                          .singleWhere((options) =>
                              options.type == slidableCoordinateType)
                          .values
                          .join(','));
                    }
                  },
                  child: Text(
                    'Get Current Data',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _slidableLineChartState?.clearChart();
                    _slidableLineChartState?.resetAnimationController();
                    setState(
                      () => testData[index].data = TestData(
                        min: min,
                        max: max,
                        divisions: divisions,
                      ).data,
                    );
                  },
                  child: Text(
                    'Clear Chat And Update Data',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
              ],
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.switchThemeFn();
        },
        child: Icon(
          Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode,
        ),
      ),
    );
  }
}
