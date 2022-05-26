import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import 'model/layer.dart';
import 'model/view.dart';

class ViewPainter extends CustomPainter {
  ViewPainter({required this.layer});

  final Layer layer;

  late final double scaleHeight = layer.scaleHeight;
  late final TextStyle? axisTextStyle = layer.axisTextStyle;
  late final Color? axisColor = layer.axisColor;
  late final Color? gridColor = layer.gridColor;
  late final Color? axisPointColor = layer.axisPointColor;
  late final Color? linkLineColor = layer.linkLineColor;
  late final Color? fillAreaColor = layer.fillAreaColor;
  late final Color? tapAreaColor = layer.tapAreaColor;
  late final bool showTapArea = layer.showTapArea;

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
  late final Paint axisPointPaint = Paint()
    ..color = axisPointColor ?? Colors.blueGrey;

  /// 连接线画笔
  late final linkLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = layer.linkLineWidth
    ..color = linkLineColor ?? Colors.blue;

  /// 范围区域画笔
  late final Paint fillAreaPaint = Paint()
    ..color = fillAreaColor ?? (axisPointColor ?? Colors.blue).withOpacity(.3);

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

    drawXAxis(canvas, size);
    drawYAxis(canvas, size);

    drawLayer(canvas, size);
  }

  /// 绘制Layer
  void drawLayer(Canvas canvas, Size size) {
    canvas.save();

    final double xStep = (size.width - scaleHeight) / layer.xAxis.length;

    final double yStep = (size.height - scaleHeight) /
        (layer.yAxisMaxValue - layer.yAxisMinValue);

    final List<View> views = layer.views;

    /// 初始化[View]中的[offset]
    for (int i = 0; i < views.length; i++) {
      if (!views[i].initialFinished) {
        views[i].offset = Offset(
          (xStep / 2) + xStep * i,
          -(size.height -
              scaleHeight -
              (views[i].initialValue - layer.yAxisMinValue) * yStep +
              views[i].height / 2),
        );
      }
    }

    drawLinkLine(canvas, linkLinePaint);
    drawFillColor(canvas, linkLinePaint);

    for (var view in views) {
      if (showTapArea) {
        view.drawTapArea(canvas, tapAreaPaint);
      }

      view.drawAxisPoint(canvas, axisPointPaint);

      var value =
          (view.rect.center.dy / yStep + layer.yAxisMaxValue).roundToDouble();

      view.drawCurrentValueText(
        canvas,
        height: size.height,
        textPainter: _textPainter,
        value: value,
      );

      if (layer.drawCheckOrClose != null) {
        bool result = layer.drawCheckOrClose!.call(value);

        if (result) {
          view.drawCheck(canvas);
        } else {
          view.drawClose(canvas);
        }
      }
    }

    canvas.restore();
  }

  /// 绘制连接线条
  void drawLinkLine(Canvas canvas, Paint paint) {
    final List<View> views = layer.views;

    final Path linePath = views.skip(1).fold(
          Path()
            ..moveTo(
              views.first.rect.center.dx,
              views.first.rect.center.dy,
            ),
          (path, view) => path
            ..lineTo(
              view.rect.center.dx,
              view.rect.center.dy,
            ),
        );

    PathMetrics pms = linePath.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        paint,
      );
    }
  }

  /// 绘制范围颜色
  void drawFillColor(Canvas canvas, Paint paint) {
    final List<View> views = layer.views;

    final Path path = views.fold(
      Path()
        ..moveTo(
          views.first.rect.center.dx,
          0,
        ),
      (path, view) => path
        ..lineTo(
          view.rect.center.dx,
          view.rect.center.dy,
        ),
    )..lineTo(
        views.last.rect.center.dx,
        0,
      );

    PathMetrics pms = path.computeMetrics();
    for (var pm in pms) {
      canvas.drawPath(
        pm.extractPath(0, pm.length),
        fillAreaPaint,
      );
    }
  }

  /// 绘制X轴
  void drawXAxis(Canvas canvas, Size size) {
    canvas.save();

    final List<String> xAxis = layer.xAxis;

    final double xStep = (size.width - scaleHeight) / xAxis.length;

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

    final List<int> yAxis = layer.yAxis;

    final double yStep = (size.height - scaleHeight) / yAxis.length;

    for (int i = yAxis.length; i >= 0; i--) {
      if (i == yAxis.length) {
        // 第一条线有轴线，所以不必绘制坐标系线
        _drawAxisText(
          canvas,
          '${layer.yAxisMaxValue}',
          offset: const Offset(-10, 2),
        );

        canvas.translate(0, -yStep);
        continue;
      } else {
        // 绘制坐标系线
        canvas.drawLine(
          Offset.zero,
          Offset(size.width - scaleHeight, 0),
          gridPaint,
        );
      }

      if (i.isEven) {
        canvas.drawLine(
          Offset(-scaleHeight, 0),
          Offset.zero,
          axisPaint,
        );
        _drawAxisText(
          canvas,
          '${yAxis[i]}',
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
