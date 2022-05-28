import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import 'model/layer.dart';
import 'model/view.dart';

class ViewPainter<E extends Enum> extends CustomPainter {
  ViewPainter({required this.layer});

  final Layer<E> layer;

  double get scaleHeight => layer.scaleHeight;
  List<List<View<E>>> get views => layer.views;

  Color get defaultAxisPointColor =>
      layer.defaultAxisPointColor ?? Colors.blueGrey;
  Color get defaultLinkLineColor => layer.defaultLinkLineColor ?? Colors.blue;
  Color get defaultFillAreaColor =>
      layer.defaultFillAreaColor ??
      layer.defaultAxisPointColor ??
      Colors.blue.withOpacity(.3);

  /// 文本绘制
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// 坐标轴画笔
  late final Paint axisPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = layer.axisColor ?? Colors.black;

  /// 坐标系线条画笔
  late final Paint gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = layer.gridColor ?? Colors.grey
    ..strokeWidth = 0.5;

  /// 坐标点画笔
  late final Paint axisPointPaint = Paint()..color = defaultAxisPointColor;

  /// 连接线画笔
  late final linkLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = layer.linkLineWidth
    ..color = defaultLinkLineColor;

  /// 范围区域画笔
  late final Paint fillAreaPaint = Paint()..color = defaultFillAreaColor;

  /// 触控区域画笔
  late final Paint tapAreaPaint = Paint()
    ..color = layer.tapAreaColor ?? Colors.red.withOpacity(.2);

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

    final double xStep = layer.getXAxisStepOffsetValue(size.width);

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

    final double yStep = layer.getYAxisStepOffsetValue(size.height);

    /// 初始化[View]中的[offset]
    for (int i = 0; i < views.length; i++) {
      for (int j = 0; j < views[i].length; j++) {
        if (!views[i][j].initialFinished) {
          views[i][j].offset = Offset(
            (xStep / 2) + xStep * j,
            layer.realValue2YAxisOffsetValue(
              views[i][j].initialValue - layer.yAxisMinValue,
              chartHeight: size.height,
              yStep: yStep,
            ),
          );
        }
      }
    }

    List<List<View<E>>> otherViews =
        layer.hasCanDragViews ? layer.views.sublist(1) : layer.views;

    for (var views in otherViews.reversed) {
      final ViewStyle? viewStyle =
          layer.getViewStyleByViewType(views.first.type);

      drawLinkLine(canvas, views: views, viewStyle: viewStyle);
      drawFillColor(canvas, views: views, viewStyle: viewStyle);
      for (var view in views) {
        view.drawAxisPoint(
          canvas,
          axisPointPaint
            ..color = viewStyle?.axisPointColor ?? defaultAxisPointColor,
        );
      }
    }

    if (layer.hasCanDragViews) {
      final ViewStyle? viewStyle =
          layer.getViewStyleByViewType(layer.canDragViews.first.type);

      drawLinkLine(canvas, views: layer.canDragViews, viewStyle: viewStyle);
      drawFillColor(canvas, views: layer.canDragViews, viewStyle: viewStyle);

      for (var view in layer.canDragViews) {
        if (layer.showTapArea) {
          view.drawTapArea(canvas, tapAreaPaint);
        }

        view.drawAxisPoint(
          canvas,
          axisPointPaint
            ..color = viewStyle?.axisPointColor ?? defaultAxisPointColor,
        );

        final double realValue = layer.yAxisOffsetValue2RealValue(
          view.offset.dy,
          yStep: yStep,
        );

        view.drawCurrentValueText(
          canvas,
          chartHeight: size.height,
          textPainter: _textPainter,
          value: realValue,
        );

        if (layer.drawCheckOrClose != null) {
          bool result = layer.drawCheckOrClose!.call(realValue);

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
        linkLinePaint..color = viewStyle?.linkLineColor ?? defaultLinkLineColor,
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
        fillAreaPaint..color = viewStyle?.fillAreaColor ?? defaultFillAreaColor,
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

    final List<String> xAxis = layer.xAxis;

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

    final List<int> yAxis = layer.yAxis;

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

      if (!layer.onlyRenderEvenYAxisText ||
          (layer.onlyRenderEvenYAxisText && i.isEven)) {
        late int value;

        if (layer.reversedYAxis) {
          if (i == yAxis.length) {
            value = layer.yAxisMinValue;
          } else {
            value = yAxis[i] + layer.yAxisStep;
          }
        } else {
          if (i == yAxis.length) {
            value = layer.yAxisMaxValue;
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
      style: layer.axisTextStyle ??
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
