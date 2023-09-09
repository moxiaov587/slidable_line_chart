import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'model/coordinates_options.dart';
import 'theme/slidable_line_chart_theme.dart';

/// [Coordinate] uses this callback to paint the value indicator on the overlay.
typedef OnDrawIndicator = bool Function(double value);

/// [CoordinateSystemPainter] uses this callback to get X-axis tick line width.
typedef GetXAxisTickLineWidth = double Function(double chartActualWidth);

/// [CoordinateSystemPainter] uses this callback to get Y-axis tick line width.
typedef GetYAxisTickLineHeight = double Function(double chartActualHeight);

/// [CoordinateSystemPainter] combines all the information to draw a line graph
/// on the canvas.
class CoordinateSystemPainter<E extends Enum> extends CustomPainter {
  /// Creates a coordinate system painter.
  CoordinateSystemPainter({
    required this.slidableCoordinateType,
    required this.xAxis,
    required this.coordinateSystemOrigin,
    required this.min,
    required this.max,
    required this.divisions,
    required this.reversed,
    required this.onlyRenderEvenAxisLabel,
    required this.onDrawCheckOrClose,
    required this.yAxis,
    required this.slidableCoordsAnimationCtrl,
    required this.otherCoordsAnimationCtrl,
    required this.getXAxisTickLineWidth,
    required this.coordinatesMap,
    required this.getYAxisTickLineHeight,
    required this.maxOffsetValueOnYAxisSlidingArea,
    required this.slidableLineChartThemeData,
  }) : super(
          repaint: Listenable.merge(
            <AnimationController?>[
              slidableCoordsAnimationCtrl,
              otherCoordsAnimationCtrl,
            ],
          ),
        );

  /// {@macro package.SlidableLineChart.slidableCoordinateType}
  final E? slidableCoordinateType;

  /// {@macro package.SlidableLineChart.xAxis}
  final List<String> xAxis;

  /// {@macro package.SlidableLineChart.coordinateSystemOrigin}
  final Offset coordinateSystemOrigin;

  /// {@macro package.SlidableLineChart.min}
  final int min;

  /// {@macro package.SlidableLineChart.max}
  final int max;

  /// {@macro package.SlidableLineChart.divisions}
  final int divisions;

  /// {@macro package.SlidableLineChart.reversed}
  final bool reversed;

  /// {@macro package.SlidableLineChart.onlyRenderEvenAxisLabel}
  final bool onlyRenderEvenAxisLabel;

  /// {@macro package.SlidableLineChart.onDrawCheckOrClose}
  final OnDrawIndicator? onDrawCheckOrClose;

  /// {@macro package.SlidableLineChartState._yAxis}
  final List<int> yAxis;

  /// {@macro package.SlidableLineChartState._slidableCoordsAnimationCtrl}
  final AnimationController? slidableCoordsAnimationCtrl;

  /// {@macro package.SlidableLineChartState._otherCoordsAnimationCtrl}
  final AnimationController? otherCoordsAnimationCtrl;

  /// {@macro package.SlidableLineChartState._getXAxisTickLineWidth}
  final GetXAxisTickLineWidth getXAxisTickLineWidth;

  /// {@macro package.SlidableLineChartState._coordinatesMap}
  final Map<E, Coordinates<E>> coordinatesMap;

  /// {@macro package.SlidableLineChartState._getYAxisTickLineHeight}
  final GetYAxisTickLineHeight getYAxisTickLineHeight;

  /// Maximum offset on the Y-axis sliding area.
  final double maxOffsetValueOnYAxisSlidingArea;

  /// {@macro package.SlidableLineChartThemeData}
  final SlidableLineChartThemeData<E>? slidableLineChartThemeData;

  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);

  late final Paint _axisLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = slidableLineChartThemeData?.axisLineColor ?? kAxisLineColor
    ..strokeWidth = slidableLineChartThemeData?.axisLineWidth ?? kAxisLineWidth;

  late final Paint _gridLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = slidableLineChartThemeData?.gridLineColor ?? kGridLineColor
    ..strokeWidth = slidableLineChartThemeData?.gridLineWidth ?? kGridLineWidth;

  final Paint _coordinatePointPaint = Paint();

  late final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = slidableLineChartThemeData?.lineWidth ?? kLineWidth;

  final Paint _fillAreaPaint = Paint();

  final Paint _tapAreaPaint = Paint();

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
    canvas.drawPath(axisLinePath, _axisLinePaint);

    final double xAxisTickLineWidth = getXAxisTickLineWidth(_chartActualWidth);

    _drawXAxis(canvas, xAxisTickLineWidth: xAxisTickLineWidth);
    _drawYAxis(canvas);

    _drawCoordinates(canvas, xAxisTickLineWidth: xAxisTickLineWidth);
  }

  void _drawCoordinates(
    Canvas canvas, {
    required double xAxisTickLineWidth,
  }) {
    final Map<E, CoordinatesStyle<E>>? coordinatesStyleMap =
        slidableLineChartThemeData?.coordinatesStyleMap;

    // Draw other coordinates first so that the slidable coordinates are drawn
    // at the top level.
    for (final Coordinates<E> coordinates in coordinatesMap.values) {
      if (coordinates.type == slidableCoordinateType) {
        continue; // Skip slidable coordinates.
      }

      final CoordinatesStyle<E>? coordinatesStyle =
          coordinatesStyleMap?[coordinates.type];

      final Color finalCoordinatePointColor = coordinatesStyle?.pointColor ??
          kColorPalette[coordinates.type.index % kColorPalette.length];

      _drawLineAndFillArea(
        canvas,
        animationController: otherCoordsAnimationCtrl,
        coordinates: coordinates,
        lineColor: coordinatesStyle?.lineColor ?? finalCoordinatePointColor,
        fillAreaColor: coordinatesStyle?.fillAreaColor ??
            finalCoordinatePointColor
                .withOpacity(0.5 * finalCoordinatePointColor.opacity),
      );

      for (final Coordinate coordinate in coordinates.value) {
        canvas.drawOval(
          coordinate.rect,
          _coordinatePointPaint..color = finalCoordinatePointColor,
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

      _drawLineAndFillArea(
        canvas,
        animationController: slidableCoordsAnimationCtrl,
        coordinates: slidableCoordinates,
        lineColor: slidableCoordinatesStyle?.lineColor ??
            finalSlidableCoordinatePointColor,
        fillAreaColor: slidableCoordinatesStyle?.fillAreaColor ??
            finalSlidableCoordinatePointColor
                .withOpacity(0.5 * finalSlidableCoordinatePointColor.opacity),
      );

      for (final Coordinate coordinate in slidableCoordinates.value) {
        if (slidableLineChartThemeData?.showTapArea ?? kShowTapArea) {
          canvas.drawOval(
            coordinate.zoomedRect,
            _tapAreaPaint
              ..color = slidableCoordinatesStyle?.tapAreaColor ??
                  finalSlidableCoordinatePointColor.withOpacity(
                    0.2 * finalSlidableCoordinatePointColor.opacity,
                  ),
          );
        }

        canvas.drawOval(
          coordinate.rect,
          _coordinatePointPaint..color = finalSlidableCoordinatePointColor,
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

  void _drawLineAndFillArea(
    Canvas canvas, {
    required AnimationController? animationController,
    required Coordinates<E> coordinates,
    required Color lineColor,
    required Color fillAreaColor,
  }) {
    final List<Coordinate> values = coordinates.value;

    final Offset first = values.first.offset;

    final double smooth = slidableLineChartThemeData?.smooth ?? kSmooth;

    late final Path linePath;

    // By https://github.com/apache/echarts/blob/master/src/chart/line/poly.ts
    if (values.length > 2 && smooth > 0.0) {
      // Is first coordinate
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

        final double lenPrevSeg = d0.distance;
        final double lenNextSeg = d1.distance;

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
          nextControlPoint0.dx.clamp(
            math.min(next.dx, current.dx),
            math.max(next.dx, current.dx),
          ),
          nextControlPoint0.dy.clamp(
            math.min(next.dy, current.dy),
            math.max(next.dy, current.dy),
          ),
        );

        // Recalculate controlPoint1 based on the adjusted controlPoint0 of next
        // segment.
        vector = Offset(
          nextControlPoint0.dx - current.dx,
          nextControlPoint0.dy - current.dy,
        );

        controlPoint1 = Offset(
          current.dx - vector.dx * lenPrevSeg / lenNextSeg,
          current.dy - vector.dy * lenPrevSeg / lenNextSeg,
        );

        // Smooth constraint between point and pre point.
        // Avoid exceeding extreme after smoothing.
        controlPoint1 = Offset(
          controlPoint1.dx.clamp(
            math.min(prev.dx, current.dx),
            math.max(prev.dx, current.dx),
          ),
          controlPoint1.dy.clamp(
            math.min(prev.dy, current.dy),
            math.max(prev.dy, current.dy),
          ),
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

        linePath.cubicTo(
          controlPoint0.dx,
          controlPoint0.dy,
          controlPoint1.dx,
          controlPoint1.dy,
          current.dx,
          current.dy,
        );

        controlPoint0 = Offset(nextControlPoint0.dx, nextControlPoint0.dy);
        prev = Offset(current.dx, current.dy);
      }

      // Is last coordinate
      final Offset last = values.last.offset;
      linePath.cubicTo(
        controlPoint0.dx,
        controlPoint0.dy,
        last.dx,
        last.dy,
        last.dx,
        last.dy,
      );
    } else {
      linePath = values.skip(1).fold<Path>(
            Path()..moveTo(first.dx, first.dy),
            (Path path, Coordinate coordinate) =>
                path..lineTo(coordinate.offset.dx, coordinate.offset.dy),
          );
    }

    final PathMetrics pathMetrics = linePath.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      final double progress =
          pathMetric.length * (animationController?.value ?? 1);

      final Path path = pathMetric.extractPath(0.0, progress);

      canvas.drawPath(path, _linePaint..color = lineColor);

      final Tangent? tangent = pathMetric.getTangentForOffset(progress);

      final Path fillAreaPath = Path()
        ..moveTo(first.dx, _chartActualHeight)
        ..addPath(path, Offset.zero)
        ..lineTo(tangent?.position.dx ?? 0.0, _chartActualHeight)
        ..lineTo(first.dx, _chartActualHeight)
        ..close();

      canvas.drawPath(
        fillAreaPath,
        _fillAreaPaint
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              fillAreaColor.withOpacity(0.2 * fillAreaColor.opacity),
              fillAreaColor,
            ],
          ).createShader(
            Rect.fromLTWH(
              first.dx,
              _chartActualHeight - maxOffsetValueOnYAxisSlidingArea,
              coordinates.value.last.offset.dx - first.dx,
              maxOffsetValueOnYAxisSlidingArea,
            ),
          ),
      );
    }
  }

  void _drawXAxis(
    Canvas canvas, {
    required double xAxisTickLineWidth,
  }) {
    canvas
      ..save()
      ..translate(
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

  void _drawYAxis(Canvas canvas) {
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
        _gridLinePaint,
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

    _textPainter
      ..text = textSpan
      ..layout();

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

    _textPainter
      ..text = textSpan
      ..layout();

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

    canvas
      ..drawCircle(Offset(x, y), radius * 2, paint)
      ..drawPath(
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

    canvas
      ..drawLine(
        Offset(x - size, y - size),
        Offset(x + size, y + size),
        paint,
      )
      ..drawLine(
        Offset(x + size, y - size),
        Offset(x - size, y + size),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CoordinateSystemPainter<E> oldDelegate) => true;
}
