import 'package:flutter/material.dart';
import 'package:slidable_line_chart/slidable_line_chart.dart';

import 'full_feat_example.dart';

void main() {
  runApp(const _SimpleExample());
}

enum CoordinateType {
  left,
  right,
  other,
}

class _SimpleExample extends StatefulWidget {
  const _SimpleExample({Key? key}) : super(key: key);

  @override
  State<_SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<_SimpleExample> {
  List<CoordinatesOptions<CoordinateType>> data = [
    CoordinatesOptions(
      CoordinateType.left,
      values: List.generate(
        6,
        (index) => 0,
      ),
    ),
    CoordinatesOptions(
      CoordinateType.right,
      values: List.generate(
        6,
        (index) => 120,
      ),
    ),
    CoordinatesOptions(
      CoordinateType.other,
      values: List.generate(
        6,
        (index) => 60,
      ),
    ),
  ];

  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xff36cfc9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff36cfc9),
          error: const Color(0xfff759ab),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xff1765ad),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xff1765ad),
          error: const Color(0xffa61d24),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple example'),
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
                  child: SlidableLineChart(
                    slidableCoordinateType: CoordinateType.values.first,
                    coordinatesOptionsList: data,
                    xAxis: const <String>['500', '1k', '2k', '4k', '6k', '8k'],
                    min: 0,
                    max: 120,
                    divisions: 10,
                    onChange:
                        (List<CoordinatesOptions<CoordinateType>> options) {
                      setState(() => data = options);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullFeatExample(
                          switchThemeFn: () {
                            setState(() => isDarkMode = !isDarkMode);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Go to full example page',
                    style: Theme.of(context).textTheme.labelLarge!,
                  ),
                ),
              ),
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
