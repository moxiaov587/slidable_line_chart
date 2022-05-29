import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import 'model/view.dart';

/// 返回bool值渲染对应图标
typedef DrawCheckOrClose = bool Function(double value);

typedef GetViewStyleByViewType<E extends Enum> = ViewStyle? Function(E type);
typedef AdjustLocalPosition = Offset Function(
  Offset localPosition, {
  required double chartHeight,
});

typedef GetAxisStepOffsetValue = double Function(double chartWidth);

typedef GetWithinRangeYAxisOffsetValue = double Function(
  double dy, {
  required double chartHeight,
  required double yStep,
  int stepFactor,
});

typedef RealValue2YAxisOffsetValue = double Function(
  double value, {
  required double chartHeight,
  required double yStep,
  int stepFactor,
});

typedef YAxisOffsetValue2RealValue = double Function(
  double yOffset, {
  required double yStep,
});

class ViewPainter<E extends Enum> extends CustomPainter {
  ViewPainter({
    required this.viewsGroup,
    required this.otherViewsGroup,
    required this.hasCanDragViews,
    required this.canDragViews,
    required this.xAxis,
    required this.yAxis,
    required this.yAxisStep,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    required this.reversedYAxis,
    required this.onlyRenderEvenYAxisText,
    required this.scaleHeight,
    required this.linkLineWidth,
    required this.axisTextStyle,
    required this.axisColor,
    required this.gridColor,
    required this.defaultAxisPointColor,
    required this.defaultLinkLineColor,
    required this.defaultFillAreaColor,
    required this.tapAreaColor,
    required this.enforceStepOffset,
    required this.showTapArea,
    required this.drawCheckOrClose,
    required this.getViewStyleByViewType,
    required this.adjustLocalPosition,
    required this.getXAxisStepOffsetValue,
    required this.getYAxisStepOffsetValue,
    required this.getWithinRangeYAxisOffsetValue,
    required this.realValue2YAxisOffsetValue,
    required this.yAxisOffsetValue2RealValue,
  });

  final List<List<View<E>>> viewsGroup;

  final List<List<View<E>>> otherViewsGroup;

  final bool hasCanDragViews;

  final List<View<E>>? canDragViews;

  /// X轴值
  final List<String> xAxis;

  /// Y轴最小值
  final int yAxisMinValue;

  /// Y轴最大值
  final int yAxisMaxValue;

  /// Y轴分隔值
  final int yAxisStep;

  /// 反转Y轴
  final bool reversedYAxis;

  /// 只渲染偶数项的Y轴文本
  final bool onlyRenderEvenYAxisText;

  /// Y轴值
  final List<int> yAxis;

  /// 刻度高度
  final double scaleHeight;

  /// 连接线的宽度
  final double linkLineWidth;

  /// 坐标轴文本样式
  final TextStyle? axisTextStyle;

  /// 坐标轴颜色
  final Color? axisColor;

  /// 坐标系网格颜色
  final Color? gridColor;

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

  final GetViewStyleByViewType<E> getViewStyleByViewType;

  final AdjustLocalPosition adjustLocalPosition;

  final GetAxisStepOffsetValue getXAxisStepOffsetValue;

  final GetAxisStepOffsetValue getYAxisStepOffsetValue;

  final GetWithinRangeYAxisOffsetValue getWithinRangeYAxisOffsetValue;

  final RealValue2YAxisOffsetValue realValue2YAxisOffsetValue;

  final YAxisOffsetValue2RealValue yAxisOffsetValue2RealValue;

  Color get axisPointColor => defaultAxisPointColor ?? Colors.blueGrey;
  Color get linkLineColor => defaultLinkLineColor ?? Colors.blue;
  Color get fillAreaColor =>
      defaultFillAreaColor ??
      defaultAxisPointColor ??
      Colors.blue.withOpacity(.3);

  /// 文本绘制
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// 坐标轴画笔
  late final Paint axisPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = axisColor ?? Colors.black;

  /// 坐标系线条画笔
  late final Paint gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = gridColor ?? Colors.grey
    ..strokeWidth = 0.5;

  /// 坐标点画笔
  late final Paint axisPointPaint = Paint()..color = axisPointColor;

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
    canvas.translate(0, size.height);
    canvas.translate(scaleHeight, -scaleHeight);

    /// 坐标轴
    final Path axisPath = Path()
      ..moveTo(-scaleHeight, 0)
      ..relativeLineTo(size.width, 0)
      ..moveTo(0, scaleHeight)
      ..relativeLineTo(0, -size.height);

    canvas.drawPath(axisPath, axisPaint);

    final double xStep = getXAxisStepOffsetValue(size.width);

    drawXAxis(canvas, size, xStep: xStep);
    drawYAxis(canvas, size);

    drawLayer(canvas, size, xStep: xStep);
  }

  /// 绘制Layer
  void drawLayer(
    Canvas canvas,
    Size size, {
    required double xStep,
  }) {
    canvas.save();

    final double yStep = getYAxisStepOffsetValue(size.height);

    /// 初始化[View]中的[offset]
    for (int i = 0; i < viewsGroup.length; i++) {
      for (int j = 0; j < viewsGroup[i].length; j++) {
        if (!viewsGroup[i][j].initialFinished) {
          viewsGroup[i][j].offset = Offset(
            (xStep / 2) + xStep * j,
            realValue2YAxisOffsetValue(
              viewsGroup[i][j].initialValue - yAxisMinValue,
              chartHeight: size.height,
              yStep: yStep,
            ),
          );
        }
      }
    }

    for (var views in otherViewsGroup.reversed) {
      final ViewStyle? viewStyle = getViewStyleByViewType(views.first.type);

      drawLinkLine(canvas, views: views, viewStyle: viewStyle);
      drawFillColor(canvas, views: views, viewStyle: viewStyle);
      for (var view in views) {
        view.drawAxisPoint(
          canvas,
          axisPointPaint..color = viewStyle?.axisPointColor ?? axisPointColor,
        );
      }
    }

    if (hasCanDragViews) {
      final ViewStyle? viewStyle =
          getViewStyleByViewType(canDragViews!.first.type);

      drawLinkLine(canvas, views: canDragViews!, viewStyle: viewStyle);
      drawFillColor(canvas, views: canDragViews!, viewStyle: viewStyle);

      for (var view in canDragViews!) {
        if (showTapArea) {
          view.drawTapArea(canvas, tapAreaPaint);
        }

        view.drawAxisPoint(
          canvas,
          axisPointPaint..color = viewStyle?.axisPointColor ?? axisPointColor,
        );

        final double realValue = yAxisOffsetValue2RealValue(
          view.offset.dy,
          yStep: yStep,
        );

        view.drawCurrentValueText(
          canvas,
          chartHeight: size.height,
          textPainter: _textPainter,
          value: realValue,
        );

        if (drawCheckOrClose != null) {
          bool result = drawCheckOrClose!.call(realValue);

          if (result) {
            view.drawCheck(canvas);
          } else {
            view.drawClose(canvas);
          }
        }
      }
    }

    canvas.restore();
  }

  /// 绘制连接线条
  void drawLinkLine(
    Canvas canvas, {
    required List<View<E>> views,
    ViewStyle? viewStyle,
  }) {
    final Path linePath = views.skip(1).fold(
          Path()
            ..moveTo(
              views.first.offset.dx,
              views.first.offset.dy,
            ),
          (path, view) => path
            ..lineTo(
              view.offset.dx,
              view.offset.dy,
            ),
        );

    PathMetrics pms = linePath.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        linkLinePaint..color = viewStyle?.linkLineColor ?? linkLineColor,
      );
    }
  }

  /// 绘制范围颜色
  void drawFillColor(
    Canvas canvas, {
    required List<View<E>> views,
    ViewStyle? viewStyle,
  }) {
    final Path path = views.fold(
      Path()
        ..moveTo(
          views.first.offset.dx,
          0,
        ),
      (path, view) => path
        ..lineTo(
          view.offset.dx,
          view.offset.dy,
        ),
    )..lineTo(
        views.last.offset.dx,
        0,
      );

    PathMetrics pms = path.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        fillAreaPaint..color = viewStyle?.fillAreaColor ?? fillAreaColor,
      );
    }
  }

  /// 绘制X轴
  void drawXAxis(
    Canvas canvas,
    Size size, {
    required double xStep,
  }) {
    canvas.save();

    canvas.translate(xStep, 0);

    for (int i = 0; i < xAxis.length; i++) {
      _drawAxisText(
        canvas,
        xAxis[i],
        alignment: Alignment.center,
        offset: Offset(-xStep / 2, 10),
      );

      canvas.translate(xStep, 0);
    }

    canvas.restore();
  }

  /// 绘制Y轴
  void drawYAxis(Canvas canvas, Size size) {
    canvas.save();

    final double yStep = (size.height - scaleHeight) / yAxis.length;

    for (int i = 0; i <= yAxis.length; i++) {
      // 第一条线有轴线，所以不必绘制坐标系线
      if (i != 0) {
        // 绘制坐标系线
        canvas.drawLine(
          Offset.zero,
          Offset(size.width - scaleHeight, 0),
          gridPaint,
        );
      }

      if (!onlyRenderEvenYAxisText || (onlyRenderEvenYAxisText && i.isEven)) {
        late int value;

        if (reversedYAxis) {
          if (i == yAxis.length) {
            value = yAxisMinValue;
          } else {
            value = yAxis[i] + yAxisStep;
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

      canvas.translate(0, -yStep);
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
  bool shouldRepaint(covariant ViewPainter oldDelegate) => true;
}
