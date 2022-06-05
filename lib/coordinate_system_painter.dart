import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import 'model/coordinate.dart';

typedef AllCoordinatesOffsetsInitializationCompleted = void Function();

/// 返回bool值渲染对应图标
typedef DrawCheckOrClose = bool Function(double value);

typedef GetCoordinateStyleByType<Enum> = CoordinateStyle? Function(Enum type);
typedef AdjustLocalPosition = Offset Function(
  Offset localPosition, {
  required double chartHeight,
});

typedef GetAxisScaleOffsetValue = double Function(double chartWidth);

typedef GetYAxisOffsetValueWithinDragRange = double Function(
  double dy, {
  required double chartHeight,
  required double yAxisScaleOffsetValue,
  int yAxisDivisions,
});

typedef CurrentValue2YAxisOffsetValue = double Function(
  double currentValue, {
  required double chartHeight,
  required double yAxisScaleOffsetValue,
  int yAxisDivisions,
});

typedef YAxisOffsetValue2CurrentValue = double Function(
  double yOffset, {
  required double yAxisScaleOffsetValue,
});

class CoordinateSystemPainter<Enum> extends CustomPainter {
  CoordinateSystemPainter({
    required this.coordinatesGroup,
    required this.allCoordinatesOffsetsUninitialized,
    required this.otherCoordinatesGroup,
    required this.hasCanDragCoordinates,
    required this.canDragCoordinates,
    required this.xAxis,
    required this.yAxis,
    required this.yAxisDivisions,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    required this.reversedYAxis,
    required this.onlyRenderEvenYAxisText,
    required this.marginLeftBottom,
    required this.linkLineWidth,
    required this.axisTextStyle,
    required this.axisLineColor,
    required this.gridLineColor,
    required this.defaultAxisPointColor,
    required this.defaultLinkLineColor,
    required this.defaultFillAreaColor,
    required this.tapAreaColor,
    required this.enforceStepOffset,
    required this.showTapArea,
    required this.allCoordinatesOffsetsInitializationCompleted,
    required this.drawCheckOrClose,
    required this.getCoordinateStyleByType,
    required this.adjustLocalPosition,
    required this.getXAxisScaleOffsetValue,
    required this.getYAxisScaleOffsetValue,
    required this.getYAxisOffsetValueWithinDragRange,
    required this.currentValue2YAxisOffsetValue,
    required this.yAxisOffsetValue2CurrentValue,
  });

  final List<List<Coordinate<Enum>>> coordinatesGroup;

  final bool allCoordinatesOffsetsUninitialized;

  final List<List<Coordinate<Enum>>> otherCoordinatesGroup;

  final bool hasCanDragCoordinates;

  final List<Coordinate<Enum>>? canDragCoordinates;

  /// X轴值
  final List<String> xAxis;

  /// Y轴最小值
  final int yAxisMinValue;

  /// Y轴最大值
  final int yAxisMaxValue;

  /// Y轴分隔值
  final int yAxisDivisions;

  /// 反转Y轴
  final bool reversedYAxis;

  /// 只渲染偶数项的Y轴文本
  final bool onlyRenderEvenYAxisText;

  /// Y轴值
  final List<int> yAxis;

  /// 刻度高度
  final double marginLeftBottom;

  /// 连接线的宽度
  final double linkLineWidth;

  /// 坐标轴文本样式
  final TextStyle? axisTextStyle;

  /// 坐标轴颜色
  final Color? axisLineColor;

  /// 坐标系网格颜色
  final Color? gridLineColor;

  /// 坐标点颜色
  final Color? defaultAxisPointColor;

  /// 连接线颜色
  final Color? defaultLinkLineColor;

  /// 覆盖区域颜色
  final Color? defaultFillAreaColor;

  /// 触摸区域颜色
  final Color? tapAreaColor;

  /// 强制步进偏移
  final bool enforceStepOffset;

  /// 显示触摸区域
  /// 一般用于调试
  final bool showTapArea;

  final DrawCheckOrClose? drawCheckOrClose;

  final AllCoordinatesOffsetsInitializationCompleted
      allCoordinatesOffsetsInitializationCompleted;

  final GetCoordinateStyleByType<Enum> getCoordinateStyleByType;

  final AdjustLocalPosition adjustLocalPosition;

  final GetAxisScaleOffsetValue getXAxisScaleOffsetValue;

  final GetAxisScaleOffsetValue getYAxisScaleOffsetValue;

  final GetYAxisOffsetValueWithinDragRange getYAxisOffsetValueWithinDragRange;

  final CurrentValue2YAxisOffsetValue currentValue2YAxisOffsetValue;

  final YAxisOffsetValue2CurrentValue yAxisOffsetValue2CurrentValue;

  Color get coordinatePointColor => defaultAxisPointColor ?? Colors.blueGrey;
  Color get linkLineColor => defaultLinkLineColor ?? Colors.blue;
  Color get fillAreaColor =>
      defaultFillAreaColor ??
      defaultAxisPointColor ??
      Colors.blue.withOpacity(.3);

  /// 文本绘制
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// 坐标轴线画笔
  late final Paint axisLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = axisLineColor ?? Colors.black;

  /// 坐标网格线画笔
  late final Paint gridLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = gridLineColor ?? Colors.grey
    ..strokeWidth = 0.5;

  /// 坐标点画笔
  late final Paint coordinatePointPaint = Paint()..color = coordinatePointColor;

  /// 连接线画笔
  late final linkLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = linkLineWidth
    ..color = linkLineColor;

  /// 范围区域画笔
  late final Paint fillAreaPaint = Paint()..color = fillAreaColor;

  /// 触控区域画笔
  late final Paint tapAreaPaint = Paint()
    ..color = tapAreaColor ?? Colors.red.withOpacity(.2);

  @override
  void paint(Canvas canvas, Size size) {
    /// 将[canvas]平移到左下角
    canvas.translate(marginLeftBottom, size.height - marginLeftBottom);

    /// 坐标轴
    final Path axisLinePath = Path()
      ..moveTo(-marginLeftBottom, 0)
      ..relativeLineTo(size.width, 0)
      ..moveTo(0, marginLeftBottom)
      ..relativeLineTo(0, -size.height);

    canvas.drawPath(axisLinePath, axisLinePaint);

    final double xAxisScaleOffsetValue = getXAxisScaleOffsetValue(size.width);

    drawXAxis(canvas, size, xAxisScaleOffsetValue: xAxisScaleOffsetValue);
    drawYAxis(canvas, size);

    drawLayer(canvas, size, xAxisScaleOffsetValue: xAxisScaleOffsetValue);
  }

  /// 绘制Layer
  void drawLayer(
    Canvas canvas,
    Size size, {
    required double xAxisScaleOffsetValue,
  }) {
    canvas.save();

    final double yAxisScaleOffsetValue = getYAxisScaleOffsetValue(size.height);

    /// 初始化[Coordinate]中的[offset]
    /// 赋予正确的X轴坐标并将当前值转换成坐标值
    if (allCoordinatesOffsetsUninitialized) {
      for (int i = 0; i < coordinatesGroup.length; i++) {
        for (int j = 0; j < coordinatesGroup[i].length; j++) {
          coordinatesGroup[i][j].offset = Offset(
            (xAxisScaleOffsetValue / 2) + xAxisScaleOffsetValue * j,
            currentValue2YAxisOffsetValue(
              coordinatesGroup[i][j].currentValue - yAxisMinValue,
              chartHeight: size.height,
              yAxisScaleOffsetValue: yAxisScaleOffsetValue,
            ),
          );
        }
      }

      allCoordinatesOffsetsInitializationCompleted.call();
    }

    /// 先绘制[otherCoordinatesGroup]使[canDragCoordinates]绘制在顶层
    for (var coordinates in otherCoordinatesGroup.reversed) {
      final CoordinateStyle? coordinateStyle =
          getCoordinateStyleByType(coordinates.first.type);

      drawLinkLine(canvas,
          coordinates: coordinates, coordinateStyle: coordinateStyle);
      drawFillColor(canvas,
          coordinates: coordinates, coordinateStyle: coordinateStyle);
      for (var coordinate in coordinates) {
        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint
            ..color =
                coordinateStyle?.coordinatePointColor ?? coordinatePointColor,
        );
      }
    }

    if (hasCanDragCoordinates) {
      final CoordinateStyle? coordinatesStyle =
          getCoordinateStyleByType(canDragCoordinates!.first.type);

      drawLinkLine(canvas,
          coordinates: canDragCoordinates!, coordinateStyle: coordinatesStyle);
      drawFillColor(canvas,
          coordinates: canDragCoordinates!, coordinateStyle: coordinatesStyle);

      for (var coordinate in canDragCoordinates!) {
        if (showTapArea) {
          coordinate.drawTapArea(canvas, tapAreaPaint);
        }

        coordinate.drawCoordinatePoint(
          canvas,
          coordinatePointPaint
            ..color =
                coordinatesStyle?.coordinatePointColor ?? coordinatePointColor,
        );

        final double currentValue = yAxisOffsetValue2CurrentValue(
          coordinate.offset.dy,
          yAxisScaleOffsetValue: yAxisScaleOffsetValue,
        );

        coordinate.drawCurrentValueText(
          canvas,
          chartHeight: size.height,
          textPainter: _textPainter,
          currentValue: currentValue,
        );

        if (drawCheckOrClose != null) {
          bool result = drawCheckOrClose!.call(currentValue);

          if (result) {
            coordinate.drawCheck(canvas);
          } else {
            coordinate.drawClose(canvas);
          }
        }
      }
    }

    canvas.restore();
  }

  /// 绘制连接线条
  void drawLinkLine(
    Canvas canvas, {
    required List<Coordinate<Enum>> coordinates,
    CoordinateStyle? coordinateStyle,
  }) {
    final Path linePath = coordinates.skip(1).fold(
          Path()
            ..moveTo(
              coordinates.first.offset.dx,
              coordinates.first.offset.dy,
            ),
          (path, coordinate) => path
            ..lineTo(
              coordinate.offset.dx,
              coordinate.offset.dy,
            ),
        );

    PathMetrics pms = linePath.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        linkLinePaint..color = coordinateStyle?.linkLineColor ?? linkLineColor,
      );
    }
  }

  /// 绘制范围颜色
  void drawFillColor(
    Canvas canvas, {
    required List<Coordinate<Enum>> coordinates,
    CoordinateStyle? coordinateStyle,
  }) {
    final Path path = coordinates.fold(
      Path()
        ..moveTo(
          coordinates.first.offset.dx,
          0,
        ),
      (path, coordinate) => path
        ..lineTo(
          coordinate.offset.dx,
          coordinate.offset.dy,
        ),
    )..lineTo(
        coordinates.last.offset.dx,
        0,
      );

    PathMetrics pms = path.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        fillAreaPaint..color = coordinateStyle?.fillAreaColor ?? fillAreaColor,
      );
    }
  }

  /// 绘制X轴
  void drawXAxis(
    Canvas canvas,
    Size size, {
    required double xAxisScaleOffsetValue,
  }) {
    canvas.save();

    canvas.translate(xAxisScaleOffsetValue, 0);

    for (int i = 0; i < xAxis.length; i++) {
      _drawAxisText(
        canvas,
        xAxis[i],
        alignment: Alignment.center,
        offset: Offset(-xAxisScaleOffsetValue / 2, 10),
      );

      canvas.translate(xAxisScaleOffsetValue, 0);
    }

    canvas.restore();
  }

  /// 绘制Y轴
  void drawYAxis(Canvas canvas, Size size) {
    canvas.save();

    final double yAxisScaleOffsetValue =
        (size.height - marginLeftBottom) / yAxis.length;

    for (int i = 0; i <= yAxis.length; i++) {
      // 第一条线有轴线，所以不必绘制坐标系线
      if (i != 0) {
        // 绘制坐标系线
        canvas.drawLine(
          Offset.zero,
          Offset(size.width - marginLeftBottom, 0),
          gridLinePaint,
        );
      }

      if (!onlyRenderEvenYAxisText || (onlyRenderEvenYAxisText && i.isEven)) {
        late int value;

        if (reversedYAxis) {
          if (i == yAxis.length) {
            value = yAxisMinValue;
          } else {
            value = yAxis[i] + yAxisDivisions;
          }
        } else {
          if (i == yAxis.length) {
            value = yAxisMaxValue;
          } else {
            value = yAxis[i];
          }
        }

        _drawAxisText(
          canvas,
          '$value',
          offset: const Offset(-10, 2),
        );
      }

      canvas.translate(0, -yAxisScaleOffsetValue);
    }
    canvas.restore();
  }

  void _drawAxisText(
    Canvas canvas,
    String text, {
    Alignment alignment = Alignment.centerRight,
    Offset offset = Offset.zero,
  }) {
    TextSpan textSpan = TextSpan(
      text: text,
      style: axisTextStyle ??
          const TextStyle(
            fontSize: 11,
            color: Colors.black,
          ),
    );

    _textPainter.text = textSpan;
    _textPainter.layout();

    final Size size = _textPainter.size;

    final Offset offsetPos =
        Offset(-size.width / 2, -size.height / 2).translate(
      -size.width / 2 * alignment.x + offset.dx,
      0.0 + offset.dy,
    );
    _textPainter.paint(canvas, offsetPos);
  }

  @override
  bool shouldRepaint(covariant CoordinateSystemPainter oldDelegate) => true;
}
