import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slidable_line_chart/model/coordinates_options.dart';
import 'package:slidable_line_chart/slidable_line_chart.dart';

enum CoordinateType {
  left,
  right,
}

void main() {
  testWidgets(
    'Slidable line chart core feature interaction',
    (WidgetTester tester) async {
      final GlobalKey<SlidableLineChartState<CoordinateType>> key =
          GlobalKey<SlidableLineChartState<CoordinateType>>();

      const double width = 300.0;
      const double height = 300.0;
      final EdgeInsets positionPadding = EdgeInsets.symmetric(
        horizontal: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dx,
        ),
        vertical: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dy,
        ),
      );
      final double actualWidth = width - positionPadding.horizontal;
      final double actualHeight = height - positionPadding.vertical;

      const List<String> xAxis = <String>['500', '1k', '2k', '4k', '6k', '8k'];
      const int min = -37;
      const int max = 12;
      const int divisions = 3;

      bool reversed = false;
      const List<double?> slidePrecisionList = <double?>[null, 1.0, 0.1, 0.01];
      int slidePrecisionIndex = 0;

      List<CoordinatesOptions<CoordinateType>> options =
          <CoordinatesOptions<CoordinateType>>[
        CoordinatesOptions<CoordinateType>(
          CoordinateType.left,
          values: <double>[
            min.toDouble(),
            ...List<double>.generate(xAxis.length - 1, (_) => max.toDouble()),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    height: height,
                    child: SlidableLineChart<CoordinateType>(
                      key: key,
                      slidableCoordinateType: CoordinateType.left,
                      coordinatesOptionsList: options,
                      xAxis: xAxis,
                      min: min,
                      max: max,
                      slidePrecision: slidePrecisionList[slidePrecisionIndex],
                      divisions: divisions,
                      reversed: reversed,
                      onChange:
                          (List<CoordinatesOptions<CoordinateType>> values) {
                        setState(() => options = values);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      key.currentState!.resetAnimationController();

                      setState(() => reversed = !reversed);
                    },
                    child: Text(
                      'Reversed',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      int data = slidePrecisionIndex + 1;
                      data = data == slidePrecisionList.length ? 0 : data;

                      setState(() => slidePrecisionIndex = data);
                    },
                    child: Text(
                      'Toggle Slide Precision',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Starts animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(2));
      await tester.pump(kDefaultInitializationAnimationDuration);
      await tester.pump(const Duration(milliseconds: 10));
      // Animation complete.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      final Offset firstCoordinateOffsetByCalculation = Offset(
        actualWidth / 2 / xAxis.length + positionPadding.left,
        actualHeight + positionPadding.bottom,
      );

      final Offset firstCoordinateOffsetByMap =
          key.currentState!.coordinatesMap.values.single.value.first.offset;
      expect(
        firstCoordinateOffsetByCalculation,
        equals(firstCoordinateOffsetByMap),
      );

      final TestGesture gesture =
          await tester.startGesture(firstCoordinateOffsetByCalculation);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

      double slidePrecision =
          (slidePrecisionList[slidePrecisionIndex] ?? divisions).toDouble();

      double minSlideUnitOffset = actualHeight /
          (key.currentState!.yAxis.length - 1) /
          (divisions / slidePrecision);

      double totalMoveDistance = 0;

      // Move up 20.
      double moveDistance = 20;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      int unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.single.values.first,
        equals(min + unitNum * slidePrecision),
      );

      // Move up 40 more.
      moveDistance = 40;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.single.values.first,
        equals(min + unitNum * slidePrecision),
      );

      // Move up to out of bounds.
      moveDistance = 300;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(options.single.values.first, equals(max));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));

      await tester.tap(find.text('Reversed'));
      await tester.pump();
      // Starts animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(2));
      await tester.pump(kDefaultInitializationAnimationDuration);
      await tester.pump(const Duration(milliseconds: 10));
      // Animation complete.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      await tester.tap(find.text('Toggle Slide Precision'));
      await tester.tap(find.text('Toggle Slide Precision'));
      await tester.pump();
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));
      expect(
        key.currentState!.slidePrecision,
        equals(slidePrecisionList[slidePrecisionIndex]),
      );

      // Pick a random one of the remaining coordinates.
      final int randomIndex = math.Random().nextInt(xAxis.length - 1) + 1;
      final double maxOffsetValueOnYAxisSlidingArea =
          (1 - key.currentState!.percentDerivedArea) * actualHeight;

      final Offset randomCoordinateOffsetByCalculation = Offset(
        actualWidth / 2 / xAxis.length +
            randomIndex * actualWidth / xAxis.length +
            positionPadding.left,
        maxOffsetValueOnYAxisSlidingArea + positionPadding.bottom,
      );

      final Offset randomCoordinateOffsetByMap = key
          .currentState!.coordinatesMap.values.single.value[randomIndex].offset;
      expect(
        randomCoordinateOffsetByCalculation,
        equals(randomCoordinateOffsetByMap),
      );

      await gesture.down(randomCoordinateOffsetByCalculation);
      expect(
        key.currentState!.currentSlideCoordinateIndex,
        equals(randomIndex),
      );
      expect(options.single.values[randomIndex], equals(max));

      slidePrecision = slidePrecisionList[slidePrecisionIndex]!;

      minSlideUnitOffset = actualHeight /
          (key.currentState!.yAxis.length - 1) /
          (divisions / slidePrecision);

      // Reset.
      totalMoveDistance = 0;

      // Move up 23.
      moveDistance = 23;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.single.values[randomIndex],
        equals(
          double.parse((max - unitNum * slidePrecision).toStringAsFixed(1)),
        ),
      );

      // Move up 46.
      moveDistance = 46;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.single.values[randomIndex],
        equals(
          double.parse((max - unitNum * slidePrecision).toStringAsFixed(1)),
        ),
      );

      // Move up to out of bounds.
      moveDistance = 300;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(options.single.values[randomIndex], equals(min));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));
    },
  );

  testWidgets(
    'Slidable line chart toggle slidable type and drags',
    (WidgetTester tester) async {
      final GlobalKey<SlidableLineChartState<CoordinateType>> key =
          GlobalKey<SlidableLineChartState<CoordinateType>>();

      const double width = 300.0;
      const double height = 300.0;
      final EdgeInsets positionPadding = EdgeInsets.symmetric(
        horizontal: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dx,
        ),
        vertical: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dy,
        ),
      );
      final double actualWidth = width - positionPadding.horizontal;
      final double actualHeight = height - positionPadding.vertical;

      const List<String> xAxis = <String>['500', '1k', '2k', '4k', '6k', '8k'];
      const int min = -12;
      const int max = 1;
      const int divisions = 1;

      List<CoordinatesOptions<CoordinateType>> options =
          <CoordinatesOptions<CoordinateType>>[
        CoordinatesOptions<CoordinateType>(
          CoordinateType.left,
          values: List<double>.generate(xAxis.length, (_) => min.toDouble()),
        ),
        CoordinatesOptions<CoordinateType>(
          CoordinateType.right,
          values: List<double>.generate(xAxis.length, (_) => max.toDouble()),
        ),
      ];

      CoordinateType? slidableCoordinateType = CoordinateType.left;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    height: height,
                    child: SlidableLineChart<CoordinateType>(
                      key: key,
                      slidableCoordinateType: slidableCoordinateType,
                      coordinatesOptionsList: options,
                      xAxis: xAxis,
                      min: min,
                      max: max,
                      onChange:
                          (List<CoordinatesOptions<CoordinateType>> values) {
                        setState(() => options = values);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
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

                      setState(() => slidableCoordinateType = type);
                    },
                    child: Text(
                      'Toggle Slidable Type',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Starts animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(2));
      await tester.pump(kDefaultInitializationAnimationDuration);
      await tester.pump(const Duration(milliseconds: 10));
      // Animation complete.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      Offset firstCoordinateOffsetByCalculation = Offset(
        actualWidth / 2 / xAxis.length + positionPadding.left,
        actualHeight + positionPadding.bottom,
      );

      Offset firstCoordinateOffsetByMap =
          key.currentState!.coordinatesMap.values.first.value.first.offset;
      expect(
        firstCoordinateOffsetByCalculation,
        equals(firstCoordinateOffsetByMap),
      );

      final TestGesture gesture =
          await tester.startGesture(firstCoordinateOffsetByCalculation);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

      final double slidePrecision = divisions.toDouble();

      final double minSlideUnitOffset = actualHeight /
          (key.currentState!.yAxis.length - 1) /
          (divisions / slidePrecision);

      double totalMoveDistance = 0;

      // Move up 20.
      double moveDistance = 20;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      int unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.first.values.first,
        equals(min + unitNum * slidePrecision),
      );

      // Move up 40 more.
      moveDistance = 40;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.first.values.first,
        equals(min + unitNum * slidePrecision),
      );

      // Move up to out of bounds.
      moveDistance = 300;
      await gesture.moveBy(
        Offset(0.0, -moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(options.first.values.first, equals(max));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));

      // Toggle slidable type to CoordinateType.right.
      await tester.tap(find.text('Toggle Slidable Type'));
      await tester.pump();
      // No animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      // Pick a random one of the remaining coordinates.
      final int randomIndex = math.Random().nextInt(xAxis.length - 1) + 1;
      final double maxOffsetValueOnYAxisSlidingArea =
          key.currentState!.percentDerivedArea * actualHeight;

      final Offset randomCoordinateOffsetByCalculation = Offset(
        actualWidth / 2 / xAxis.length +
            randomIndex * actualWidth / xAxis.length +
            positionPadding.left,
        maxOffsetValueOnYAxisSlidingArea + positionPadding.bottom,
      );

      final Offset randomCoordinateOffsetByMap = key
          .currentState!.coordinatesMap.values.last.value[randomIndex].offset;
      expect(
        randomCoordinateOffsetByCalculation,
        equals(randomCoordinateOffsetByMap),
      );

      await gesture.down(randomCoordinateOffsetByCalculation);
      expect(
        key.currentState!.currentSlideCoordinateIndex,
        equals(randomIndex),
      );
      expect(options.last.values[randomIndex], equals(max));

      // Reset.
      totalMoveDistance = 0;

      // Move down 23.
      moveDistance = 23;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.last.values[randomIndex],
        equals(max - unitNum * slidePrecision),
      );

      // Move down 46 more.
      moveDistance = 46;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.last.values[randomIndex],
        equals(max - unitNum * slidePrecision),
      );

      // Move down to out of bounds.
      moveDistance = 300;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(options.last.values[randomIndex], equals(min));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));

      // Toggle slidable type to null.
      await tester.tap(find.text('Toggle Slidable Type'));
      await tester.pump();
      // No animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      // After move.
      firstCoordinateOffsetByCalculation = Offset(
        firstCoordinateOffsetByCalculation.dx,
        maxOffsetValueOnYAxisSlidingArea + positionPadding.bottom,
      );

      firstCoordinateOffsetByMap =
          key.currentState!.coordinatesMap.values.first.value.first.offset;
      expect(
        firstCoordinateOffsetByCalculation,
        equals(firstCoordinateOffsetByMap),
      );

      await gesture.down(firstCoordinateOffsetByCalculation);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));
      await gesture.up();

      // Toggle slidable type to CoordinateType.left.
      await tester.tap(find.text('Toggle Slidable Type'));
      await tester.pump();
      // No animation.
      expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

      await gesture.down(firstCoordinateOffsetByCalculation);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

      // Reset.
      totalMoveDistance = 0;

      // Move down 17.
      moveDistance = 17;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.first.values.first,
        equals(max - unitNum * slidePrecision),
      );

      // Move down 39 more.
      moveDistance = 39;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(
        options.first.values.first,
        equals(max - unitNum * slidePrecision),
      );

      // Move down to out of bounds.
      moveDistance = 300;
      await gesture.moveBy(
        Offset(0.0, moveDistance),
        timeStamp: const Duration(milliseconds: 100),
      );
      totalMoveDistance += moveDistance;
      unitNum = (totalMoveDistance / minSlideUnitOffset).round();
      expect(options.first.values.first, equals(min));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));
    },
  );

  testWidgets(
    'Slidable line chart onChangeStart and onChangeEnd fire once',
    (WidgetTester tester) async {
      final GlobalKey<SlidableLineChartState<CoordinateType>> key =
          GlobalKey<SlidableLineChartState<CoordinateType>>();

      int startFired = 0;
      int endFired = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 300.0,
                  height: 300.0,
                  child: SlidableLineChart<CoordinateType>(
                    key: key,
                    slidableCoordinateType: CoordinateType.left,
                    coordinatesOptionsList: <CoordinatesOptions<
                        CoordinateType>>[
                      CoordinatesOptions<CoordinateType>(
                        CoordinateType.left,
                        values: List<double>.generate(6, (_) => 0.0),
                      ),
                    ],
                    xAxis: const <String>['500', '1k', '2k', '4k', '6k', '8k'],
                    min: 0,
                    max: 120,
                    divisions: 10,
                    onChange:
                        (List<CoordinatesOptions<CoordinateType>> values) {},
                    onChangeStart:
                        (List<CoordinatesOptions<CoordinateType>> values) {
                      startFired += 1;
                    },
                    onChangeEnd:
                        (List<CoordinatesOptions<CoordinateType>> values) {
                      endFired += 1;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final TestGesture gesture = await tester.startGesture(
        key.currentState!.coordinatesMap.values.single.value.first.offset,
      );

      await gesture.moveBy(
        const Offset(0.0, -20.0),
        timeStamp: const Duration(milliseconds: 100),
      );
      expect(startFired, equals(1));

      await gesture.up();
      expect(endFired, equals(1));
    },
  );

  testWidgets(
    'Coordinate point zoomedRect bounds should respond to touch events',
    (WidgetTester tester) async {
      final GlobalKey<SlidableLineChartState<CoordinateType>> key =
          GlobalKey<SlidableLineChartState<CoordinateType>>();

      const double width = 300.0;
      const double height = 300.0;
      final EdgeInsets positionPadding = EdgeInsets.symmetric(
        horizontal: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dx,
        ),
        vertical: math.max(
          kDefaultCoordinatesOptionsRadius *
              kDefaultCoordinatesOptionsZoomedFactor,
          kDefaultCoordinateSystemOrigin.dy,
        ),
      );
      final double actualWidth = width - positionPadding.horizontal;
      final double actualHeight = height - positionPadding.vertical;

      const List<String> xAxis = <String>['500', '1k', '2k', '4k', '6k', '8k'];
      const int min = 0;
      const int max = 120;
      const int divisions = 10;

      bool reversed = false;
      const List<double?> slidePrecisionList = <double?>[null, 1.0, 0.1, 0.01];
      int slidePrecisionIndex = 0;

      List<CoordinatesOptions<CoordinateType>> options =
          <CoordinatesOptions<CoordinateType>>[
        CoordinatesOptions<CoordinateType>(
          CoordinateType.left,
          values: <double>[
            min.toDouble(),
            ...List<double>.generate(xAxis.length - 1, (_) => max.toDouble()),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    height: height,
                    child: SlidableLineChart<CoordinateType>(
                      key: key,
                      slidableCoordinateType: CoordinateType.left,
                      coordinatesOptionsList: options,
                      xAxis: xAxis,
                      min: min,
                      max: max,
                      slidePrecision: slidePrecisionList[slidePrecisionIndex],
                      divisions: divisions,
                      reversed: reversed,
                      onChange:
                          (List<CoordinatesOptions<CoordinateType>> values) {
                        setState(() => options = values);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      key.currentState!.resetAnimationController();

                      setState(() => reversed = !reversed);
                    },
                    child: Text(
                      'Reversed',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      int data = slidePrecisionIndex + 1;
                      data = data == slidePrecisionList.length ? 0 : data;

                      setState(() => slidePrecisionIndex = data);
                    },
                    child: Text(
                      'Toggle Slide Precision',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final Offset firstCoordinateOffsetByCalculation = Offset(
        actualWidth / 2 / xAxis.length + positionPadding.left,
        actualHeight + positionPadding.bottom,
      );

      Coordinate firstCoordinate =
          key.currentState!.coordinatesMap.values.single.value.first;

      expect(
        firstCoordinateOffsetByCalculation,
        equals(firstCoordinate.offset),
      );

      // See [Rect.contains].
      final Offset bottomBoundPoint =
          Offset(firstCoordinateOffsetByCalculation.dx, height - 0.1);
      expect(
        firstCoordinate.hitTest(bottomBoundPoint),
        true,
      );

      TestGesture gesture = await tester.startGesture(bottomBoundPoint);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));

      await tester.tap(find.text('Reversed'));
      await tester.pump();

      firstCoordinate =
          key.currentState!.coordinatesMap.values.single.value.first;

      expect(
        Offset(firstCoordinateOffsetByCalculation.dx, positionPadding.top),
        equals(firstCoordinate.offset),
      );

      final Offset topBoundPoint = Offset(
        firstCoordinateOffsetByCalculation.dx,
        0.0,
      );
      expect(
        firstCoordinate.hitTest(topBoundPoint),
        true,
      );

      gesture = await tester.startGesture(topBoundPoint);
      expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

      await gesture.up();
      expect(key.currentState!.currentSlideCoordinateIndex, equals(null));
    },
  );

  testWidgets('Drags with the larger coordinateSystemOrigin',
      (WidgetTester tester) async {
    final GlobalKey<SlidableLineChartState<CoordinateType>> key =
        GlobalKey<SlidableLineChartState<CoordinateType>>();

    const Offset coordinateSystemOrigin = Offset(60.0, 60.0);
    const double width = 300.0;
    const double height = 300.0;
    final EdgeInsets positionPadding = EdgeInsets.symmetric(
      horizontal: math.max(
        kDefaultCoordinatesOptionsRadius *
            kDefaultCoordinatesOptionsZoomedFactor,
        coordinateSystemOrigin.dx,
      ),
      vertical: math.max(
        kDefaultCoordinatesOptionsRadius *
            kDefaultCoordinatesOptionsZoomedFactor,
        coordinateSystemOrigin.dy,
      ),
    );
    final double actualWidth = width - positionPadding.horizontal;
    final double actualHeight = height - positionPadding.vertical;

    const List<String> xAxis = <String>['500', '1k', '2k', '4k', '6k', '8k'];
    const int min = -37;
    const int max = 13;
    const int divisions = 3;

    List<CoordinatesOptions<CoordinateType>> options =
        <CoordinatesOptions<CoordinateType>>[
      CoordinatesOptions<CoordinateType>(
        CoordinateType.left,
        values: List<double>.generate(xAxis.length, (_) => min.toDouble()),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: width,
                  height: height,
                  child: SlidableLineChart<CoordinateType>(
                    key: key,
                    slidableCoordinateType: CoordinateType.left,
                    coordinatesOptionsList: options,
                    coordinateSystemOrigin: coordinateSystemOrigin,
                    xAxis: xAxis,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChange:
                        (List<CoordinatesOptions<CoordinateType>> values) {
                      setState(() => options = values);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Starts animation.
    expect(SchedulerBinding.instance.transientCallbackCount, equals(2));
    await tester.pump(kDefaultInitializationAnimationDuration);
    await tester.pump(const Duration(milliseconds: 10));
    // Animation complete.
    expect(SchedulerBinding.instance.transientCallbackCount, equals(0));

    final Offset firstCoordinateOffsetByCalculation = Offset(
      actualWidth / 2 / xAxis.length + positionPadding.left,
      actualHeight + positionPadding.bottom,
    );

    final Offset firstCoordinateOffsetByMap =
        key.currentState!.coordinatesMap.values.first.value.first.offset;
    expect(
      firstCoordinateOffsetByCalculation,
      equals(firstCoordinateOffsetByMap),
    );

    final TestGesture gesture =
        await tester.startGesture(firstCoordinateOffsetByCalculation);
    expect(key.currentState!.currentSlideCoordinateIndex, equals(0));

    final double slidePrecision = divisions.toDouble();

    final double minSlideUnitOffset = actualHeight /
        (key.currentState!.yAxis.length - 1) /
        (divisions / slidePrecision);

    double totalMoveDistance = 0;

    // Move up 20.
    double moveDistance = 20;
    await gesture.moveBy(
      Offset(0.0, -moveDistance),
      timeStamp: const Duration(milliseconds: 100),
    );
    totalMoveDistance += moveDistance;
    int unitNum = (totalMoveDistance / minSlideUnitOffset).round();
    expect(
      options.first.values.first,
      equals(min + unitNum * slidePrecision),
    );

    // Move up 40 more.
    moveDistance = 40;
    await gesture.moveBy(
      Offset(0.0, -moveDistance),
      timeStamp: const Duration(milliseconds: 100),
    );
    totalMoveDistance += moveDistance;
    unitNum = (totalMoveDistance / minSlideUnitOffset).round();
    expect(
      options.first.values.first,
      equals(min + unitNum * slidePrecision),
    );

    // Move up to out of bounds.
    moveDistance = 300;
    await gesture.moveBy(
      Offset(0.0, -moveDistance),
      timeStamp: const Duration(milliseconds: 100),
    );
    totalMoveDistance += moveDistance;
    unitNum = (totalMoveDistance / minSlideUnitOffset).round();
    expect(options.first.values.first, equals(max));
  });
}
