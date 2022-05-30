library flutter_line_chart;

export 'model/view.dart';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'model/view.dart';
import 'layer_painter.dart';

typedef ViewsValueCallback = void Function(List<double> viewsValue);

typedef AllViewsCallback<E extends Enum> = void Function(
    List<View<E>> currentViews);

class FlutterLineChart<E extends Enum> extends StatefulWidget {
  const FlutterLineChart({
    Key? key,
    required this.viewTypeValues,
    this.canDragViewType,
    required this.allViews,
    required this.xAxis,
    required this.yAxisStep,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    this.onChangeAllViewsCallback,
    this.onChangeEndAllViewsCallback,
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
    this.onChange,
    this.onChangeEnd,
  }) : super(key: key);

  final List<E> viewTypeValues;

  final E? canDragViewType;

  final Map<E, ViewStyle>? viewStyles;

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

  final AllViewsCallback<E>? onChangeAllViewsCallback;

  final AllViewsCallback<E>? onChangeEndAllViewsCallback;

  /// 反转Y轴
  final bool reversedYAxis;

  /// 只渲染偶数项的Y轴文本
  final bool onlyRenderEvenYAxisText;

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

  final ViewsValueCallback? onChange;

  final ViewsValueCallback? onChangeEnd;

  @override
  State<FlutterLineChart<E>> createState() => _FlutterLineChartState<E>();
}

class _FlutterLineChartState<E extends Enum>
    extends State<FlutterLineChart<E>> {
  ViewStyle? getViewStyleByViewType(E type) => widget.viewStyles?[type];

  View<E>? _currentSelectedView;

  bool get hasCanDragViews => canDragViews != null;

  List<View<E>>? get canDragViews {
    var data =
        viewsGroup.where((views) => views.first.type == _canDragViewType);

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  List<List<View<E>>> get otherViewsGroup => viewsGroup
      .where((views) => views.first.type != _canDragViewType)
      .toList();

  List<double>? get currentViewsValue =>
      canDragViews?.map((view) => view.currentValue).toList();

  Offset adjustLocalPosition(
    Offset localPosition, {
    required double chartHeight,
  }) =>
      localPosition.translate(-widget.scaleHeight, -chartHeight);

  double getXAxisStepOffsetValue(double chartWidth) =>
      (chartWidth - widget.scaleHeight) / widget.xAxis.length;

  double getYAxisStepOffsetValue(double chartHeight) =>
      (chartHeight - widget.scaleHeight) /
      (widget.yAxisMaxValue - widget.yAxisMinValue);

  double getWithinRangeYAxisOffsetValue(
    double dy, {
    required double chartHeight,
    required double yStep,
    int stepFactor = 1,
  }) =>
      ((dy - chartHeight) / stepFactor)
          .clamp(
            (widget.scaleHeight - chartHeight) / stepFactor,
            0,
          )
          .floorToDouble() +
      widget.yAxisMinValue * yStep;

  double realValue2YAxisOffsetValue(
    double value, {
    required double chartHeight,
    required double yStep,
    int stepFactor = 1,
  }) =>
      (widget.reversedYAxis
          ? -(chartHeight - widget.scaleHeight - value * yStep)
          : -value * yStep) *
      stepFactor;

  double yAxisOffsetValue2RealValue(
    double yOffset, {
    required double yStep,
  }) =>
      (widget.reversedYAxis
              ? (yOffset / yStep + widget.yAxisMaxValue)
              : -(yOffset / yStep - widget.yAxisMinValue))
          .roundToDouble();

  View<E>? hintTestView(Offset position) => canDragViews?.reversed
      .firstWhereOrNull((view) => view.hintTestView(position));

  late E _canDragViewType;

  /// Y轴值
  late List<int> yAxis;

  late List<List<View<E>>> viewsGroup;

  @override
  void initState() {
    super.initState();

    _canDragViewType = widget.canDragViewType ?? widget.viewTypeValues.first;
    yAxis = widget.reversedYAxis
        ? List.generate(
            (widget.yAxisMaxValue - widget.yAxisMinValue) ~/ widget.yAxisStep,
            (int index) =>
                widget.yAxisMinValue +
                index * widget.yAxisStep).reversed.toList()
        : List.generate(
            (widget.yAxisMaxValue - widget.yAxisMinValue) ~/ widget.yAxisStep,
            (int index) =>
                widget.yAxisMinValue + index * widget.yAxisStep).toList();
    viewsGroup = widget.viewTypeValues
        .fold<List<List<View<E>>?>>(
          <List<View<E>>?>[],
          (previousValue, type) {
            List<View<E>>? data =
                widget.allViews.where((view) => view.type == type).toList();

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
  }

  @override
  void didUpdateWidget(covariant FlutterLineChart<E> oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needRebuild = false;

    if (oldWidget.canDragViewType != widget.canDragViewType) {
      _canDragViewType = widget.canDragViewType ?? widget.viewTypeValues.first;

      needRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.yAxisMaxValue != widget.yAxisMaxValue ||
        oldWidget.yAxisMinValue != widget.yAxisMinValue ||
        oldWidget.yAxisStep != widget.yAxisStep) {
      yAxis = widget.reversedYAxis
          ? List.generate(
              (widget.yAxisMaxValue - widget.yAxisMinValue) ~/ widget.yAxisStep,
              (int index) =>
                  widget.yAxisMinValue +
                  index * widget.yAxisStep).reversed.toList()
          : List.generate(
              (widget.yAxisMaxValue - widget.yAxisMinValue) ~/ widget.yAxisStep,
              (int index) =>
                  widget.yAxisMinValue + index * widget.yAxisStep).toList();

      needRebuild = true;
    }

    if (oldWidget.viewTypeValues.map((type) => type.hashCode).join() !=
            widget.viewTypeValues.map((type) => type.hashCode).join() ||
        oldWidget.allViews.map((views) => views.hashCode).join() !=
            widget.allViews.map((views) => views.hashCode).join()) {
      viewsGroup = widget.viewTypeValues
          .fold<List<List<View<E>>?>>(
            <List<View<E>>?>[],
            (previousValue, type) {
              List<View<E>>? data =
                  widget.allViews.where((view) => view.type == type).toList();

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

      needRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.onlyRenderEvenYAxisText != widget.onlyRenderEvenYAxisText ||
        oldWidget.scaleHeight != widget.scaleHeight ||
        oldWidget.linkLineWidth != widget.linkLineWidth ||
        oldWidget.axisTextStyle != widget.axisTextStyle ||
        oldWidget.axisColor != widget.axisColor ||
        oldWidget.gridColor != widget.gridColor ||
        oldWidget.defaultAxisPointColor != widget.defaultAxisPointColor ||
        oldWidget.defaultLinkLineColor != widget.defaultLinkLineColor ||
        oldWidget.defaultFillAreaColor != widget.defaultFillAreaColor ||
        oldWidget.viewStyles.hashCode != widget.viewStyles.hashCode ||
        oldWidget.tapAreaColor != widget.tapAreaColor ||
        oldWidget.enforceStepOffset != widget.enforceStepOffset ||
        oldWidget.showTapArea != widget.showTapArea) {
      needRebuild = true;
    }

    if (_currentSelectedView != null &&
        !widget.allViews.contains(_currentSelectedView)) {
      _currentSelectedView = widget.allViews
          .firstWhereOrNull((view) => view.id == _currentSelectedView!.id);
    }

    if (needRebuild) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        return GestureDetector(
          onVerticalDragDown: (DragDownDetails details) {
            _currentSelectedView = hintTestView(
              adjustLocalPosition(
                details.localPosition,
                chartHeight: chartHeight,
              ),
            );

            if (_currentSelectedView != null) {
              HapticFeedback.mediumImpact();
            }
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (_currentSelectedView != null) {
              late double dy;

              final double yStep = getYAxisStepOffsetValue(chartHeight);

              if (widget.enforceStepOffset) {
                dy = getWithinRangeYAxisOffsetValue(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yStep: yStep,
                  stepFactor: widget.yAxisStep,
                );

                final double realValue = yAxisOffsetValue2RealValue(
                  dy,
                  yStep: yStep,
                );

                dy = realValue2YAxisOffsetValue(
                  realValue,
                  chartHeight: chartHeight,
                  yStep: yStep,
                  stepFactor: widget.yAxisStep,
                );
              } else {
                dy = getWithinRangeYAxisOffsetValue(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yStep: yStep,
                );
              }

              _currentSelectedView!.offset = Offset(
                _currentSelectedView!.offset.dx,
                dy,
              );

              widget.onChangeAllViewsCallback
                  ?.call(widget.allViews.map<View<E>>((view) => view).toList());

              if (currentViewsValue != null) {
                widget.onChange?.call(currentViewsValue!);
              }
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {
            widget.onChangeEndAllViewsCallback
                ?.call(widget.allViews.map((view) => view).toList());

            _currentSelectedView = null;

            if (currentViewsValue != null) {
              widget.onChangeEnd?.call(currentViewsValue!);
            }
          },
          onVerticalDragCancel: () {
            _currentSelectedView = null;
          },
          child: CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: ViewPainter<E>(
              viewsGroup: viewsGroup,
              otherViewsGroup: otherViewsGroup,
              hasCanDragViews: hasCanDragViews,
              canDragViews: canDragViews,
              xAxis: widget.xAxis,
              yAxis: yAxis,
              yAxisStep: widget.yAxisStep,
              yAxisMaxValue: widget.yAxisMaxValue,
              yAxisMinValue: widget.yAxisMinValue,
              reversedYAxis: widget.reversedYAxis,
              onlyRenderEvenYAxisText: widget.onlyRenderEvenYAxisText,
              scaleHeight: widget.scaleHeight,
              linkLineWidth: widget.linkLineWidth,
              axisTextStyle: widget.axisTextStyle,
              axisColor: widget.axisColor,
              gridColor: widget.gridColor,
              defaultAxisPointColor: widget.defaultAxisPointColor,
              defaultLinkLineColor: widget.defaultLinkLineColor,
              defaultFillAreaColor: widget.defaultFillAreaColor,
              tapAreaColor: widget.tapAreaColor,
              enforceStepOffset: widget.enforceStepOffset,
              showTapArea: widget.showTapArea,
              drawCheckOrClose: widget.drawCheckOrClose,
              getViewStyleByViewType: getViewStyleByViewType,
              adjustLocalPosition: adjustLocalPosition,
              getXAxisStepOffsetValue: getXAxisStepOffsetValue,
              getYAxisStepOffsetValue: getYAxisStepOffsetValue,
              getWithinRangeYAxisOffsetValue: getWithinRangeYAxisOffsetValue,
              realValue2YAxisOffsetValue: realValue2YAxisOffsetValue,
              yAxisOffsetValue2RealValue: yAxisOffsetValue2RealValue,
            ),
          ),
        );
      },
    );
  }
}
