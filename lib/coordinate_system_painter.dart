import 'dart:ui';

import 'package:flutter/material.dart';

import 'model/coordinates_options.dart';
import 'theme/slidable_line_chart_theme.dart';

typedef CoordinateDisplayValueChanged = bool Function(double value);

typedef GetXAxisTickLineWidth = double Function(double chartWidth);

typedef GetYAxisTickLineHeight = double Function(double chartHeight);

class CoordinateSystemPainter<Enum> extends CustomPainter {
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

  final AnimationController? slidableCoordinatesAnimationController;

  final AnimationController? otherCoordinatesAnimationController;

  final Enum? slidableCoordinateType;

  final Map<Enum, Coordinates<Enum>> coordinatesMap;

  final List<String> xAxis;

  final List<int> yAxis;

  final int min;

  final int max;

  final double maxOffsetValueOnYAxisSlidingArea;

  final Offset coordinateSystemOrigin;

  final int divisions;

  final bool reversed;

  final bool onlyRenderEvenAxisLabel;

  final SlidableLineChartThemeData<Enum>? slidableLineChartThemeData;

  final CoordinateDisplayValueChanged? onDrawCheckOrClose;

  final GetXAxisTickLineWidth getXAxisTickLineWidth;

  final GetYAxisTickLineHeight getYAxisTickLineHeight;

  Color get defaultCoordinatePointColor =>
      slidableLineChartThemeData?.defaultCoordinatePointColor ??
      kDefaultCoordinatePointColor;
  Color get defaultLineColor =>
      slidableLineChartThemeData?.defaultLineColor ?? kDefaultLineColor;
  Color get defaultFillAreaColor =>
      slidableLineChartThemeData?.defaultFillAreaColor ??
      slidableLineChartThemeData?.defaultCoordinatePointColor ??
      kDefaultFillAreaColor;

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

  @override
  void paint(Canvas canvas, Size size) {
    // Move the [canvas] starting point to [coordinateSystemOrigin]
    canvas.translate(
      coordinateSystemOrigin.dx,
      size.height - coordinateSystemOrigin.dy,
    );

    final Path axisLinePath = Path()
      ..moveTo(-coordinateSystemOrigin.dx, 0)
      ..relativeLineTo(size.width, 0)
      ..moveTo(0, coordinateSystemOrigin.dy)
      ..relativeLineTo(0, -size.height);

    canvas.drawPath(axisLinePath, axisLinePaint);

    final double xAxisTickLineWidth = getXAxisTickLineWidth(size.width);

    drawXAxis(canvas, size, xAxisTickLineWidth: xAxisTickLineWidth);
    drawYAxis(canvas, size);

    drawCoordinates(canvas, size, xAxisTickLineWidth: xAxisTickLineWidth);
  }

  void drawCoordinates(
    Canvas canvas,
    Size size, {
    required double xAxisTickLineWidth,
  }) {
    canvas.save();

    // Draw other coordinates first so that the slidable coordinates are drawn at
    // the top level.
    for (final Coordinates<Enum> coordinates in coordinatesMap.values) {
      if (coordinates.type == slidableCoordinateType) {
        continue; // Skip slidable coordinates.
      }
      drawLineAndFillArea(
        canvas,
        animationController: otherCoordinatesAnimationController,
        coordinates: coordinates,
        coordinateStyle: coordinates.style,
      );

      for (final Coordinate coordinate in coordinates.value) {
        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint
            ..color =
                coordinates.style?.pointColor ?? defaultCoordinatePointColor,
        );
      }
    }

    final Coordinates<Enum>? slidableCoordinates =
        coordinatesMap[slidableCoordinateType];

    if (slidableCoordinates != null) {
      drawLineAndFillArea(
        canvas,
        animationController: slidableCoordinatesAnimationController,
        coordinates: slidableCoordinates,
        coordinateStyle: slidableCoordinates.style,
      );

      for (final Coordinate coordinate in slidableCoordinates.value) {
        if (slidableLineChartThemeData?.showTapArea ?? kShowTapArea) {
          coordinate.drawTapArea(
            canvas,
            tapAreaPaint
              ..color = slidableCoordinates.style?.tapAreaColor ??
                  slidableCoordinates.style?.pointColor?.withOpacity(.2) ??
                  slidableLineChartThemeData?.defaultTapAreaColor ??
                  kTapAreaColor.withOpacity(.2),
          );
        }

        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint
            ..color = slidableCoordinates.style?.pointColor ??
                defaultCoordinatePointColor,
        );

        _drawDisplayValueText(
          canvas,
          dx: coordinate.offset.dx,
          chartHeight: size.height,
          displayValue: coordinate.displayValue,
        );

        final bool? result = onDrawCheckOrClose?.call(coordinate.displayValue);

        switch (result) {
          case null:
            break;
          case true:
            _drawCheck(canvas, dx: coordinate.offset.dx);
            break;
          case false:
            _drawClose(canvas, dx: coordinate.offset.dx);
            break;
        }
      }
    }

    canvas.restore();
  }

  void drawLineAndFillArea(
    Canvas canvas, {
    required AnimationController? animationController,
    required Coordinates<Enum> coordinates,
    CoordinatesStyle<Enum>? coordinateStyle,
  }) {
    final Offset firstCoordinateOffset = coordinates.value.first.offset;

    final Color finalFillAreaColor =
        coordinateStyle?.fillAreaColor ?? defaultFillAreaColor;

    final Path linePath = coordinates.value.skip(1).fold<Path>(
          Path()..moveTo(firstCoordinateOffset.dx, firstCoordinateOffset.dy),
          (Path path, Coordinate coordinate) =>
              path..lineTo(coordinate.offset.dx, coordinate.offset.dy),
        );

    final PathMetrics pathMetrics = linePath.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      final double progress =
          pathMetric.length * (animationController?.value ?? 1);

      final Path path = pathMetric.extractPath(0.0, progress);

      canvas.drawPath(
        path,
        linePaint..color = coordinateStyle?.lineColor ?? defaultLineColor,
      );

      final Tangent? tangent = pathMetric.getTangentForOffset(progress);

      final Path fillAreaPath = Path()
        ..moveTo(firstCoordinateOffset.dx, 0.0)
        ..addPath(path, Offset.zero)
        ..lineTo(tangent?.position.dx ?? 0.0, 0.0)
        ..lineTo(firstCoordinateOffset.dx, 0.0)
        ..close();

      canvas.drawPath(
        fillAreaPath,
        fillAreaPaint
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              finalFillAreaColor.withOpacity(0.2),
              finalFillAreaColor,
            ],
          ).createShader(
            Rect.fromLTRB(
              firstCoordinateOffset.dx,
              -maxOffsetValueOnYAxisSlidingArea,
              coordinates.value.last.offset.dx,
              -coordinateSystemOrigin.dy,
            ),
          ),
      );
    }
  }

  void drawXAxis(
    Canvas canvas,
    Size size, {
    required double xAxisTickLineWidth,
  }) {
    canvas.save();

    canvas.translate(xAxisTickLineWidth, 0);

    final Offset axisLabelOffset = Offset(
        -xAxisTickLineWidth / 2,
        slidableLineChartThemeData?.axisLabelStyle?.fontSize ??
            kAxisLabelStyle.fontSize!);

    for (int i = 0; i < xAxis.length; i++) {
      _drawAxisLabel(
        canvas,
        xAxis[i],
        alignment: Alignment.center,
        offset: axisLabelOffset,
      );

      canvas.translate(xAxisTickLineWidth, 0);
    }

    canvas.restore();
  }

  void drawYAxis(Canvas canvas, Size size) {
    canvas.save();

    final double yAxisTickLineHeight = getYAxisTickLineHeight(size.height);

    final Offset axisLabelOffset = Offset(
        -(slidableLineChartThemeData?.axisLabelStyle?.fontSize ??
            kAxisLabelStyle.fontSize!),
        0);

    // The first line has an axis, so only text is drawn.
    _drawAxisLabel(
      canvas,
      yAxis[0].toString(),
      offset: axisLabelOffset,
    );

    canvas.translate(0, -yAxisTickLineHeight);

    for (int i = 1; i < yAxis.length; i++) {
      // Drawing coordinate line.
      canvas.drawLine(
        Offset.zero,
        Offset(size.width - coordinateSystemOrigin.dx, 0),
        gridLinePaint,
      );

      if (!onlyRenderEvenAxisLabel || (onlyRenderEvenAxisLabel && i.isEven)) {
        _drawAxisLabel(
          canvas,
          yAxis[i].toString(),
          offset: axisLabelOffset,
        );
      }

      canvas.translate(0, -yAxisTickLineHeight);
    }
    canvas.restore();
  }

  void _drawAxisLabel(
    Canvas canvas,
    String text, {
    Alignment alignment = Alignment.centerRight,
    Offset offset = Offset.zero,
  }) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: slidableLineChartThemeData?.axisLabelStyle ?? kAxisLabelStyle,
    );

    _textPainter.text = textSpan;
    _textPainter.layout();

    final Size size = _textPainter.size;

    final Offset offsetPos =
        Offset(-size.width / 2, -size.height / 2).translate(
      -size.width / 2 * alignment.x + offset.dx,
      offset.dy,
    );
    _textPainter.paint(canvas, offsetPos);
  }

  void _drawDisplayValueText(
    Canvas canvas, {
    required double dx,
    required double chartHeight,
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

    final Offset offsetPos =
        Offset(-size.width / 2, -size.height / 2).translate(
      dx,
      -chartHeight -
          (slidableLineChartThemeData?.displayValueMarginBottom ??
              kDisplayValueMarginBottom), // Makes the display value top.
    );
    _textPainter.paint(canvas, offsetPos);
  }

  void _drawCheck(
    Canvas canvas, {
    required double dx,
  }) {
    final double x = dx;
    final double y = slidableLineChartThemeData?.checkOrCloseIconMarginTop ??
        kCheckOrCloseIconMarginTop;
    final double radius =
        slidableLineChartThemeData?.indicatorRadius ?? kIndicatorRadius;

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
    required double dx,
  }) {
    final double x = dx;
    final double y = slidableLineChartThemeData?.checkOrCloseIconMarginTop ??
        kCheckOrCloseIconMarginTop;
    final double radius =
        slidableLineChartThemeData?.indicatorRadius ?? kIndicatorRadius;
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
  bool shouldRepaint(covariant CoordinateSystemPainter<Enum> oldDelegate) =>
      true;
}
