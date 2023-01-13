import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'model/coordinates_options.dart';
import 'theme/slidable_line_chart_theme.dart';

typedef OnDrawIndicator = bool Function(double value);

typedef GetXAxisTickLineWidth = double Function(double chartActualWidth);

typedef GetYAxisTickLineHeight = double Function(double chartActualHeight);

class CoordinateSystemPainter<E extends Enum> extends CustomPainter {
  CoordinateSystemPainter({
    required this.slidableCoordinatesAnimationController,
    required this.otherCoordinatesAnimationController,
    required this.slidableCoordinateType,
    required this.coordinatesMap,
    required this.xAxis,
    required this.yAxis,
    required this.min,
    required this.max,
    required this.maxOffsetValueOnYAxisSlidingArea,
    required this.coordinateSystemOrigin,
    required this.divisions,
    required this.reversed,
    required this.onlyRenderEvenAxisLabel,
    required this.slidableLineChartThemeData,
    required this.onDrawCheckOrClose,
    required this.getXAxisTickLineWidth,
    required this.getYAxisTickLineHeight,
  }) : super(
          repaint: Listenable.merge(
            <AnimationController?>[
              slidableCoordinatesAnimationController,
              otherCoordinatesAnimationController,
            ],
          ),
        );

  /// {@macro slidable_line_chart.SlidableLineChartState._slidableCoordinatesAnimationController}
  final AnimationController? slidableCoordinatesAnimationController;

  /// {@macro slidable_line_chart.SlidableLineChartState._otherCoordinatesAnimationController}
  final AnimationController? otherCoordinatesAnimationController;

  /// {@macro slidable_line_chart.SlidableLineChart.slidableCoordinateType}
  final E? slidableCoordinateType;

  /// {@macro slidable_line_chart.SlidableLineChartState._coordinatesMap}
  final Map<E, Coordinates<E>> coordinatesMap;

  /// {@macro slidable_line_chart.SlidableLineChart.xAxis}
  final List<String> xAxis;

  /// {@macro slidable_line_chart.SlidableLineChartState._yAxis}
  final List<int> yAxis;

  /// {@macro slidable_line_chart.SlidableLineChart.min}
  final int min;

  /// {@macro slidable_line_chart.SlidableLineChart.max}
  final int max;

  final double maxOffsetValueOnYAxisSlidingArea;

  /// {@macro slidable_line_chart.SlidableLineChart.coordinateSystemOrigin}
  final Offset coordinateSystemOrigin;

  /// {@macro slidable_line_chart.SlidableLineChart.divisions}
  final int divisions;

  /// {@macro slidable_line_chart.SlidableLineChart.reversed}
  final bool reversed;

  /// {@macro slidable_line_chart.SlidableLineChart.onlyRenderEvenAxisLabel}
  final bool onlyRenderEvenAxisLabel;

  final SlidableLineChartThemeData<E>? slidableLineChartThemeData;

  /// {@macro slidable_line_chart.SlidableLineChart.onDrawCheckOrClose}
  final OnDrawIndicator? onDrawCheckOrClose;

  /// {@macro slidable_line_chart.SlidableLineChartState._getXAxisTickLineWidth}
  final GetXAxisTickLineWidth getXAxisTickLineWidth;

  /// {@macro slidable_line_chart.SlidableLineChartState._getYAxisTickLineHeight}
  final GetYAxisTickLineHeight getYAxisTickLineHeight;

  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);

  late final Paint axisLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = slidableLineChartThemeData?.axisLineColor ?? kAxisLineColor
    ..strokeWidth = slidableLineChartThemeData?.axisLineWidth ?? kAxisLineWidth;

  late final Paint gridLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = slidableLineChartThemeData?.gridLineColor ?? kGridLineColor
    ..strokeWidth = slidableLineChartThemeData?.gridLineWidth ?? kGridLineWidth;

  final Paint coordinatePointPaint = Paint();

  late final Paint linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = slidableLineChartThemeData?.lineWidth ?? kLineWidth;

  final Paint fillAreaPaint = Paint();

  final Paint tapAreaPaint = Paint();

  late double _chartWidth;
  late double _chartHeight;

  late double _chartActualWidth;
  late double _chartActualHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _chartWidth = size.width;
    _chartHeight = size.height;

    _chartActualWidth = _chartWidth - coordinateSystemOrigin.dx;
    _chartActualHeight = _chartHeight - coordinateSystemOrigin.dy;

    final Path axisLinePath = Path()
      // X-Axis
      ..moveTo(0.0, _chartActualHeight)
      ..relativeLineTo(_chartWidth, 0.0)
      // Y-Axis
      ..moveTo(coordinateSystemOrigin.dx, 0.0)
      ..relativeLineTo(0.0, _chartHeight);
    canvas.drawPath(axisLinePath, axisLinePaint);

    final double xAxisTickLineWidth = getXAxisTickLineWidth(_chartActualWidth);

    drawXAxis(canvas, xAxisTickLineWidth: xAxisTickLineWidth);
    drawYAxis(canvas);

    drawCoordinates(canvas, xAxisTickLineWidth: xAxisTickLineWidth);
  }

  void drawCoordinates(
    Canvas canvas, {
    required double xAxisTickLineWidth,
  }) {
    final Map<E, CoordinatesStyle<E>>? coordinatesStyleMap =
        slidableLineChartThemeData?.coordinatesStyleMap;

    // Draw other coordinates first so that the slidable coordinates are drawn at
    // the top level.
    for (final Coordinates<E> coordinates in coordinatesMap.values) {
      if (coordinates.type == slidableCoordinateType) {
        continue; // Skip slidable coordinates.
      }

      final CoordinatesStyle<E>? coordinatesStyle =
          coordinatesStyleMap?[coordinates.type];

      final Color finalCoordinatePointColor = coordinatesStyle?.pointColor ??
          kColorPalette[coordinates.type.index % kColorPalette.length];

      drawLineAndFillArea(
        canvas,
        animationController: otherCoordinatesAnimationController,
        coordinates: coordinates,
        lineColor: coordinatesStyle?.lineColor ?? finalCoordinatePointColor,
        fillAreaColor:
            coordinatesStyle?.fillAreaColor ?? finalCoordinatePointColor,
      );

      for (final Coordinate coordinate in coordinates.value) {
        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint..color = finalCoordinatePointColor,
        );
      }
    }

    final Coordinates<E>? slidableCoordinates =
        coordinatesMap[slidableCoordinateType];

    if (slidableCoordinates != null) {
      final CoordinatesStyle<E>? slidableCoordinatesStyle =
          coordinatesStyleMap?[slidableCoordinates.type];

      final Color finalSlidableCoordinatePointColor = slidableCoordinatesStyle
              ?.pointColor ??
          kColorPalette[slidableCoordinateType!.index % kColorPalette.length];

      drawLineAndFillArea(
        canvas,
        animationController: slidableCoordinatesAnimationController,
        coordinates: slidableCoordinates,
        lineColor: slidableCoordinatesStyle?.lineColor ??
            finalSlidableCoordinatePointColor,
        fillAreaColor: slidableCoordinatesStyle?.fillAreaColor ??
            finalSlidableCoordinatePointColor,
      );

      for (final Coordinate coordinate in slidableCoordinates.value) {
        if (slidableLineChartThemeData?.showTapArea ?? kShowTapArea) {
          coordinate.drawTapArea(
            canvas,
            tapAreaPaint
              ..color = slidableCoordinatesStyle?.tapAreaColor ??
                  finalSlidableCoordinatePointColor.withOpacity(.2),
          );
        }

        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint..color = finalSlidableCoordinatePointColor,
        );

        _drawDisplayValueText(
          canvas,
          dx: coordinate.offset.dx,
          displayValue: coordinate.value,
        );

        final bool? result = onDrawCheckOrClose?.call(coordinate.value);

        final double radius =
            slidableLineChartThemeData?.indicatorRadius ?? kIndicatorRadius;

        final double y = (slidableLineChartThemeData?.indicatorMarginTop ??
                kIndicatorMarginTop) +
            _chartHeight;

        switch (result) {
          case null:
            break;
          case true:
            _drawCheck(canvas, radius: radius, x: coordinate.offset.dx, y: y);
            break;
          case false:
            _drawClose(canvas, radius: radius, x: coordinate.offset.dx, y: y);
            break;
        }
      }
    }
  }

  void drawLineAndFillArea(
    Canvas canvas, {
    required AnimationController? animationController,
    required Coordinates<E> coordinates,
    required Color lineColor,
    required Color fillAreaColor,
  }) {
    final Offset firstCoordinateOffset = coordinates.value.first.offset;

    final double smooth = slidableLineChartThemeData?.smooth ?? kSmooth;

    late final Path linePath;

    final List<Coordinate> values = coordinates.value;

    // By https://github.com/apache/echarts/blob/master/src/chart/line/poly.ts
    if (values.length > 2 && smooth > 0.0) {
      // Is first coordinate
      final Offset first = values.first.offset;
      linePath = Path()..moveTo(first.dx, first.dy);
      Offset controlPoint0 = Offset(first.dx, first.dy);
      Offset prev = Offset(first.dx, first.dy);

      late Offset controlPoint1;

      for (int index = 1; index < values.length - 1; index++) {
        final Offset current = values[index].offset;
        final Offset next = values[index + 1].offset;

        double ratio = 0.5;
        Offset vector = Offset.zero;
        late Offset nextControlPoint0;

        vector = Offset(next.dx - prev.dx, next.dy - prev.dy);

        final Offset d0 = Offset(current.dx - prev.dx, current.dy - prev.dy);
        final Offset d1 = Offset(next.dx - current.dx, next.dy - current.dy);

        final double lenPrevSeg = math.sqrt(d0.dx * d0.dx + d0.dy * d0.dy);
        final double lenNextSeg = math.sqrt(d1.dx * d1.dx + d1.dy * d1.dy);

        // Use ratio of segment length.
        ratio = lenNextSeg / (lenNextSeg + lenPrevSeg);

        controlPoint1 = Offset(
          current.dx - vector.dx * smooth * (1 - ratio),
          current.dy - vector.dy * smooth * (1 - ratio),
        );

        // controlPoint0 of next segment.
        nextControlPoint0 = Offset(
          current.dx + vector.dx * smooth * ratio,
          current.dy + vector.dy * smooth * ratio,
        );

        // Smooth constraint between point and next point.
        // Avoid exceeding extreme after smoothing.
        nextControlPoint0 = Offset(
          math.min(nextControlPoint0.dx, math.max(next.dx, current.dx)),
          math.min(nextControlPoint0.dy, math.max(next.dy, current.dy)),
        );
        nextControlPoint0 = Offset(
          math.max(nextControlPoint0.dx, math.min(next.dx, current.dx)),
          math.max(nextControlPoint0.dy, math.min(next.dy, current.dy)),
        );

        // Recalculate controlPoint1 based on the adjusted controlPoint0 of next
        // segment.
        vector = Offset(nextControlPoint0.dx - current.dx,
            nextControlPoint0.dy - current.dy);

        controlPoint1 = Offset(current.dx - vector.dx * lenPrevSeg / lenNextSeg,
            current.dy - vector.dy * lenPrevSeg / lenNextSeg);

        // Smooth constraint between point and pre point.
        // Avoid exceeding extreme after smoothing.
        controlPoint1 = Offset(
          math.min(controlPoint1.dx, math.max(prev.dx, current.dx)),
          math.min(controlPoint1.dy, math.max(prev.dy, current.dy)),
        );
        controlPoint1 = Offset(
          math.max(controlPoint1.dx, math.min(prev.dx, current.dx)),
          math.max(controlPoint1.dy, math.min(prev.dy, current.dy)),
        );

        // Adjust nextControlPoint0 again.
        vector = Offset(
          current.dx - controlPoint1.dx,
          current.dy - controlPoint1.dy,
        );
        nextControlPoint0 = Offset(
          current.dx + vector.dx * lenNextSeg / lenPrevSeg,
          current.dy + vector.dy * lenNextSeg / lenPrevSeg,
        );

        linePath.cubicTo(controlPoint0.dx, controlPoint0.dy, controlPoint1.dx,
            controlPoint1.dy, current.dx, current.dy);

        controlPoint0 = Offset(nextControlPoint0.dx, nextControlPoint0.dy);
        prev = Offset(current.dx, current.dy);
      }

      // Is last coordinate
      final Offset last = values.last.offset;
      linePath.cubicTo(controlPoint0.dx, controlPoint0.dy, last.dx, last.dy,
          last.dx, last.dy);
    } else {
      linePath = values.skip(1).fold<Path>(
            Path()..moveTo(firstCoordinateOffset.dx, firstCoordinateOffset.dy),
            (Path path, Coordinate coordinate) =>
                path..lineTo(coordinate.offset.dx, coordinate.offset.dy),
          );
    }

    final PathMetrics pathMetrics = linePath.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      final double progress =
          pathMetric.length * (animationController?.value ?? 1);

      final Path path = pathMetric.extractPath(0.0, progress);

      canvas.drawPath(path, linePaint..color = lineColor);

      final Tangent? tangent = pathMetric.getTangentForOffset(progress);

      final Path fillAreaPath = Path()
        ..moveTo(firstCoordinateOffset.dx, _chartActualHeight)
        ..addPath(path, Offset.zero)
        ..lineTo(tangent?.position.dx ?? 0.0, _chartActualHeight)
        ..lineTo(firstCoordinateOffset.dx, _chartActualHeight)
        ..close();

      canvas.drawPath(
        fillAreaPath,
        fillAreaPaint
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              fillAreaColor.withOpacity(0.2),
              fillAreaColor,
            ],
          ).createShader(
            Rect.fromLTWH(
              firstCoordinateOffset.dx,
              _chartActualHeight - maxOffsetValueOnYAxisSlidingArea,
              coordinates.value.last.offset.dx - firstCoordinateOffset.dx,
              maxOffsetValueOnYAxisSlidingArea,
            ),
          ),
      );
    }
  }

  void drawXAxis(
    Canvas canvas, {
    required double xAxisTickLineWidth,
  }) {
    canvas.save();

    canvas.translate(
      xAxisTickLineWidth / 2 + coordinateSystemOrigin.dx,
      _chartHeight,
    );

    for (int i = 0; i < xAxis.length; i++) {
      _drawAxisLabel(
        canvas,
        xAxis[i],
        drawXAxis: true,
        alignment: Alignment.center,
      );

      canvas.translate(xAxisTickLineWidth, 0);
    }

    canvas.restore();
  }

  void drawYAxis(Canvas canvas) {
    canvas.save();

    final double yAxisTickLineHeight =
        getYAxisTickLineHeight(_chartActualHeight);

    canvas.translate(
      coordinateSystemOrigin.dx,
      _chartActualHeight,
    );

    // The first line has an axis, so only text is drawn.
    _drawAxisLabel(
      canvas,
      yAxis[0].toString(),
    );

    canvas.translate(0.0, -yAxisTickLineHeight);

    for (int i = 1; i < yAxis.length; i++) {
      // Drawing coordinate line.
      canvas.drawLine(
        Offset.zero,
        Offset(_chartActualWidth, 0),
        gridLinePaint,
      );

      if (!onlyRenderEvenAxisLabel || (onlyRenderEvenAxisLabel && i.isEven)) {
        _drawAxisLabel(
          canvas,
          yAxis[i].toString(),
        );
      }

      canvas.translate(0.0, -yAxisTickLineHeight);
    }
    canvas.restore();
  }

  void _drawAxisLabel(
    Canvas canvas,
    String text, {
    bool drawXAxis = false,
    Alignment alignment = Alignment.centerLeft,
  }) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: slidableLineChartThemeData?.axisLabelStyle ?? kAxisLabelStyle,
    );

    _textPainter.text = textSpan;
    _textPainter.layout();

    final Size size = _textPainter.size;

    late double dx;
    late double dy;

    if (drawXAxis) {
      dx = 0.0;
      dy = size.height / 2;
    } else {
      dx = size.width + coordinateSystemOrigin.dx;
      dy = 0.0;
    }

    final Offset offset = Offset(-size.width / 2, -size.height / 2).translate(
      -size.width / 2 * alignment.x - dx,
      dy,
    );
    _textPainter.paint(canvas, offset);
  }

  void _drawDisplayValueText(
    Canvas canvas, {
    required double dx,
    required double displayValue,
  }) {
    final TextSpan textSpan = TextSpan(
      text: displayValue.toString(),
      style: slidableLineChartThemeData?.displayValueTextStyle ??
          kDisplayValueTextStyle,
    );

    _textPainter.text = textSpan;
    _textPainter.layout();

    final Size size = _textPainter.size;

    final Offset offset = Offset(-size.width / 2, -size.height).translate(
      dx,
      -(slidableLineChartThemeData?.displayValueMarginBottom ??
          kDisplayValueMarginBottom), // Makes the display value top.
    );
    _textPainter.paint(canvas, offset);
  }

  void _drawCheck(
    Canvas canvas, {
    required double radius,
    required double x,
    required double y,
  }) {
    final Path checkPath = Path()
      ..addPolygon(
        <Offset>[
          Offset(x - radius, y),
          Offset(x - radius / 3, y + (radius - radius / 3)),
          Offset(x + radius, y - radius * 2 / 3)
        ],
        false,
      );

    final Paint paint = Paint()
      ..color = slidableLineChartThemeData?.checkBackgroundColor ??
          kCheckBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius * 2, paint);

    canvas.drawPath(
      checkPath,
      paint
        ..color = slidableLineChartThemeData?.checkColor ?? kCheckColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.4,
    );
  }

  void _drawClose(
    Canvas canvas, {
    required double radius,
    required double x,
    required double y,
  }) {
    final double size = radius * 0.8;

    Paint paint = Paint()
      ..color = slidableLineChartThemeData?.closeBackgroundColor ??
          kCloseBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius * 2, paint);

    paint = paint
      ..color = slidableLineChartThemeData?.closeColor ?? kCloseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.4;

    canvas.drawLine(
      Offset(x - size, y - size),
      Offset(x + size, y + size),
      paint,
    );

    canvas.drawLine(
      Offset(x + size, y - size),
      Offset(x - size, y + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CoordinateSystemPainter<E> oldDelegate) => true;
}
