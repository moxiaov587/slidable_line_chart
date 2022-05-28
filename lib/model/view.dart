import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

class View {
  View({
    required this.initialValue,
    this.width = 12,
    this.height = 12,
    this.zoomedFactor = 3.0,
    this.currentValueTextStyle,
    this.currentValueMarginBottomValue = 10.0,
    this.checkOrCloseIconMarginTop = 30.0,
    this.checkOrCloseIconSize = 10.0,
    this.closeSize = 4.0,
    this.checkBackground,
    this.closeBackground,
    this.checkColor,
    this.closeColor,
  }) : offset = Offset(0, initialValue);

  final double initialValue;
  final double width;
  final double height;
  Offset offset;

  final double zoomedFactor;
  // 当前值文本样式
  final TextStyle? currentValueTextStyle;

  final double currentValueMarginBottomValue;

  final double checkOrCloseIconMarginTop;
  final double checkOrCloseIconSize;
  final double closeSize;
  final Color? checkBackground;
  final Color? closeBackground;

  final Color? checkColor;
  final Color? closeColor;

  late double _currentValue = initialValue;

  double get currentValue => _currentValue;

  bool get initialFinished => offset.dx != 0;

  Rect get rect => Rect.fromCenter(
        center: offset,
        width: width,
        height: height,
      );

  /// 放大的[Rect]
  /// 用于增大触摸生效的判定区域
  Rect get zoomedRect => Rect.fromCenter(
        center: offset,
        width: width * zoomedFactor,
        height: height * zoomedFactor,
      );

  bool hintTestView(Offset position) => zoomedRect.contains(position);

  void drawAxisPoint(Canvas canvas, Paint paint) {
    canvas.drawOval(rect, paint);
  }

  void drawTapArea(Canvas canvas, Paint paint) {
    canvas.drawOval(zoomedRect, paint);
  }

  void drawCurrentValueText(
    Canvas canvas, {
    required double chartHeight, // 用于偏移使文字居顶
    required TextPainter textPainter,
    required double value,
  }) {
    _currentValue = value;

    TextSpan textSpan = TextSpan(
      text: value.toInt().toString(),
      style: currentValueTextStyle ??
          const TextStyle(
            fontSize: 14,
            color: Colors.blueGrey,
          ),
    );

    textPainter.text = textSpan;
    textPainter.layout();

    Size size = textPainter.size;

    Offset offsetPos = Offset(-size.width / 2, -size.height / 2)
        .translate(offset.dx, -chartHeight - currentValueMarginBottomValue);
    textPainter.paint(canvas, offsetPos);
  }

  void drawCheck(Canvas canvas) {
    final double x = offset.dx;
    final double y = checkOrCloseIconMarginTop;
    final double radius = checkOrCloseIconSize;

    final Path checkPath = Path()
      ..addPolygon(
        [
          Offset(x - 1 / 2 * radius, y),
          Offset(x - radius / 6, y + (radius / 2 - radius / 6)),
          Offset(x + radius * 1 / 2, y - radius * 1 / 3)
        ],
        false,
      );

    final Paint paint = Paint()
      ..color = checkBackground ?? Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, paint);

    canvas.drawPath(
      checkPath,
      paint
        ..color = checkColor ?? Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void drawClose(Canvas canvas) {
    final double x = offset.dx;
    final double y = checkOrCloseIconMarginTop;
    final double radius = checkOrCloseIconSize;
    final double size = closeSize;

    Paint paint = Paint()
      ..color = closeBackground ?? Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, paint);

    paint = paint
      ..color = closeColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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
}
