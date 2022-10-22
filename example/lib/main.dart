import 'dart:math';

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
    required this.min,
    required this.max,
    required this.divisions,
  }) : data = [
          CoordinatesOptions(
            CoordinateType.left,
            values: List.generate(
              6,
              (index) => (Random().nextInt(max - min) + min).toDouble(),
            ),
          ),
          CoordinatesOptions(
            CoordinateType.right,
            values: List.generate(
              6,
              (index) => (Random().nextInt(max - min) + min).toDouble(),
            ),
          ),
        ];

  final List<CoordinatesOptions<CoordinateType>> data;
  final int min;
  final int max;
  final int divisions;
}

const List<double?> slidePrecisionList = [null, 1.0, 0.1, 0.01];

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  final List<TestData> testData = [
    TestData(
      min: -37,
      max: 12,
      divisions: 3,
    ),
    TestData(
      min: -12,
      max: 1,
      divisions: 2,
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

  int index = 0;

  int slidePrecisionIndex = 0;

  final GlobalKey<SlidableLineChartState<CoordinateType>> _key =
      GlobalKey<SlidableLineChartState<CoordinateType>>();

  SlidableLineChartState<CoordinateType>? get _slidableLineChartState =>
      _key.currentState;

  List<CoordinatesOptions<CoordinateType>> get coordinatesOptionsList =>
      testData[index].data;

  int get min => testData[index].min;
  int get max => testData[index].max;
  int get divisions => testData[index].divisions;

  double? get slidePrecision => slidePrecisionList[slidePrecisionIndex];

  CoordinateType? slidableCoordinateType = CoordinateType.left;

  bool reversed = false;
  bool enableInitializationAnimation = true;

  String? result;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xff36cfc9),
        errorColor: const Color(0xfff759ab),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xff1765ad),
        errorColor: const Color(0xffa61d24),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SlidableLineChart example app'),
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
                    data: SlidableLineChartThemeData<CoordinateType>(
                      coordinatesStyleList: [
                        CoordinatesStyle<CoordinateType>(
                          type: CoordinateType.left,
                          pointColor: Theme.of(context).primaryColor,
                          lineColor: Theme.of(context).primaryColor,
                          fillAreaColor:
                              Theme.of(context).primaryColor.withOpacity(.5),
                        ),
                        CoordinatesStyle<CoordinateType>(
                          type: CoordinateType.right,
                          pointColor: Theme.of(context).errorColor,
                          lineColor: Theme.of(context).errorColor,
                          fillAreaColor:
                              Theme.of(context).errorColor.withOpacity(.5),
                        ),
                      ],
                      showTapArea: true,
                    ),
                    child: SlidableLineChart(
                      key: _key,
                      slidableCoordinateType: slidableCoordinateType,
                      coordinatesOptionsList: coordinatesOptionsList,
                      xAxis: const <String>[
                        '500',
                        '1k',
                        '2k',
                        '4k',
                        '6k',
                        '8k'
                      ],
                      min: min,
                      max: max,
                      divisions: divisions,
                      slidePrecision: slidePrecision,
                      reversed: reversed,
                      // onlyRenderEvenAxisLabel: false,
                      enableInitializationAnimation:
                          enableInitializationAnimation,
                      // initializationAnimationDuration:
                      //     const Duration(milliseconds: 1000),
                      onDrawCheckOrClose: (double value) {
                        return value >= 30;
                      },
                      onChangeEnd: (List<double> data) {
                        setState(() => result = data.join(','));
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
                      CoordinateType? type;
                      switch (slidableCoordinateType) {
                        case null:
                          type = CoordinateType.left;
                          break;
                        case CoordinateType.left:
                          type = CoordinateType.right;
                          break;
                        case CoordinateType.right:
                          break;
                      }

                      setState(() {
                        result = null;
                        slidableCoordinateType = type;
                      });
                    },
                    child: Text(
                      'Toggle Slidable Type',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => reversed = !reversed);
                    },
                    child: Text(
                      'Reversed',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => enableInitializationAnimation =
                          !enableInitializationAnimation);
                    },
                    child: Text(
                      '${enableInitializationAnimation ? 'Disable' : 'Enable'} Animation',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int data = slidePrecisionIndex + 1;
                      data = data == slidePrecisionList.length ? 0 : data;

                      setState(() {
                        slidePrecisionIndex = data;
                      });
                    },
                    child: Text(
                      'Toggle Slide Precision',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int data = index + 1;
                      data = data == testData.length ? 0 : data;

                      setState(() {
                        result = null;
                        index = data;
                      });
                    },
                    child: Text(
                      'Toggle Test Data',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _slidableLineChartState?.reset();

                      if (_slidableLineChartState?.displayValues != null) {
                        setState(() => result =
                            _slidableLineChartState!.displayValues!.join(','));
                      }
                    },
                    child: Text(
                      'Reset',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (slidableCoordinateType == null) {
                        setState(() => result = 'No Slidable Coordinates');
                      } else {
                        if (_slidableLineChartState?.displayValues != null) {
                          setState(() => result = _slidableLineChartState!
                              .displayValues!
                              .join(','));
                        }
                      }
                    },
                    child: Text(
                      'Get Current Data',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              )
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() => isDarkMode = !isDarkMode);
          },
          child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}
