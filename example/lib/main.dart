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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                        builder: (_) => const FullFeatExample(),
                      ),
                    );
                  },
                  child: Text(
                    'Go to full example page',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
