import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'view.dart';

/// 返回bool值渲染对应图标
typedef DrawCheckOrClose = bool Function(double value);

class Layer {
  Layer({
    required this.views,
    required this.xAxis,
    required this.yAxisStep,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    this.scaleHeight = 8.0,
    this.linkLineWidth = 2.0,
    this.axisTextStyle,
    this.axisColor,
    this.gridColor,
    this.axisPointColor,
    this.linkLineColor,
    this.fillAreaColor,
    this.tapAreaColor,
    this.showTapArea = false,
    this.drawCheckOrClose,
  }) : yAxis = List.generate((yAxisMaxValue - yAxisMinValue) ~/ yAxisStep,
            (int index) => index * yAxisStep).toList();

  /// 点集
  final List<View> views;

  /// X轴值
  final List<String> xAxis;

  /// Y轴最小值
  final int yAxisMinValue;

  /// Y轴最大值
  final int yAxisMaxValue;

  /// Y轴分隔值
  final int yAxisStep;

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
  final Color? axisPointColor;

  /// 连接线颜色
  final Color? linkLineColor;

  /// 覆盖区域颜色
  final Color? fillAreaColor;

  /// 触摸区域颜色
  final Color? tapAreaColor;

  /// 显示触摸区域
  /// 一般用于调试
  final bool showTapArea;

  final DrawCheckOrClose? drawCheckOrClose;

  List<int> get currentViewsValue =>
      views.map((view) => view.currentValue.abs().toInt()).toList();

  View? hintTestView(Offset position) =>
      views.reversed.firstWhereOrNull((view) => view.hintTestView(position));
}
