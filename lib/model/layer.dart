import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'view.dart';

/// 返回bool值渲染对应图标
typedef DrawCheckOrClose = bool Function(double value);

class Layer<E extends Enum> {
  Layer({
    required this.viewTypeValues,
    required this.allViews,
    required this.xAxis,
    required this.yAxisStep,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    this.reversedYAxis = false,
    this.onlyRenderEvenYAxisText = true,
    this.scaleHeight = 8.0,
    this.linkLineWidth = 2.0,
    this.axisTextStyle,
    this.axisColor,
    this.gridColor,
    this.defaultAxisPointColor,
    this.defaultLinkLineColor,
    this.defaultFillAreaColor,
    this.viewStyles,
    this.tapAreaColor,
    this.enforceStepOffset = false,
    this.showTapArea = false,
    this.drawCheckOrClose,
  }) : yAxis = reversedYAxis
            ? List.generate((yAxisMaxValue - yAxisMinValue) ~/ yAxisStep,
                    (int index) => yAxisMinValue + index * yAxisStep)
                .reversed
                .toList()
            : List.generate((yAxisMaxValue - yAxisMinValue) ~/ yAxisStep,
                (int index) => yAxisMinValue + index * yAxisStep).toList();

  final List<E> viewTypeValues;

  final Map<E, ViewStyle>? viewStyles;

  ViewStyle? getViewStyleByViewType(E type) => viewStyles?[type];

  /// 点集
  final List<View<E>> allViews;

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

  List<List<View<E>>> get views => viewTypeValues
      .fold<List<List<View<E>>?>>(
        <List<View<E>>?>[],
        (previousValue, type) {
          List<View<E>>? data =
              allViews.where((view) => view.type == type).toList();

          if (data.isEmpty) {
            data = null;
          }

          return [
            ...previousValue,
            data,
          ];
        },
      )
      .whereType<List<View<E>>>()
      .toList();

  bool get hasCanDragViews => views.first.first.canDrag;

  List<View<E>> get canDragViews => views.first;

  List<int>? get currentViewsValue => hasCanDragViews
      ? canDragViews.map((view) => view.currentValue.abs().toInt()).toList()
      : null;

  Offset adjustLocalPosition(
    Offset localPosition, {
    required double chartHeight,
  }) =>
      localPosition.translate(-scaleHeight, -chartHeight);

  double getXAxisStepOffsetValue(double chartWidth) =>
      (chartWidth - scaleHeight) / xAxis.length;

  double getYAxisStepOffsetValue(double chartHeight) =>
      (chartHeight - scaleHeight) / (yAxisMaxValue - yAxisMinValue);

  double getWithinRangeYAxisOffsetValue(
    double dy, {
    required double chartHeight,
    int stepFactor = 1,
  }) =>
      ((dy - chartHeight) / stepFactor)
          .clamp(
            (scaleHeight - chartHeight) / stepFactor,
            0,
          )
          .floorToDouble();

  double realValue2YAxisOffsetValue(
    double value, {
    required double chartHeight,
    required double yStep,
    int stepFactor = 1,
  }) =>
      (reversedYAxis
          ? -(chartHeight - scaleHeight - value * yStep)
          : -value * yStep) *
      stepFactor;

  double yAxisOffsetValue2RealValue(
    double yOffset, {
    required double yStep,
  }) =>
      (reversedYAxis
              ? (yOffset / yStep + yAxisMaxValue)
              : -(yOffset / yStep + yAxisMinValue))
          .roundToDouble();

  View<E>? hintTestView(Offset position) => hasCanDragViews
      ? canDragViews.reversed
          .firstWhereOrNull((view) => view.hintTestView(position))
      : null;
}
