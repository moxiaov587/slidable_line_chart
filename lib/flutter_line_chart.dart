library flutter_line_chart;

export 'model/coordinate.dart';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'model/coordinate.dart';
import 'coordinate_system_painter.dart';

typedef CanDragCoordinatesValueCallback = void Function(
    List<double> canDragCoordinatesValue);

class FlutterLineChart<Enum> extends StatefulWidget {
  const FlutterLineChart({
    Key? key,
    this.canDragCoordinateType,
    required this.allCoordinates,
    required this.xAxis,
    required this.yAxisDivisions,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    this.reversedYAxis = false,
    this.onlyRenderEvenYAxisText = true,
    this.marginLeftBottom = 8.0,
    this.linkLineWidth = 2.0,
    this.axisTextStyle,
    this.axisLineColor,
    this.gridLineColor,
    this.defaultCoordinatePointColor,
    this.defaultLinkLineColor,
    this.defaultFillAreaColor,
    this.coordinateStyles,
    this.tapAreaColor,
    this.enforceStepOffset = false,
    this.showTapArea = false,
    this.drawCheckOrClose,
    this.onChange,
    this.onChangeEnd,
  })  : assert(yAxisMaxValue > yAxisMinValue,
            'yAxisMaxValue($yAxisMaxValue) must be larger than yAxisMinValue($yAxisMinValue)'),
        assert(yAxisDivisions > 0,
            'yAxisDivisions($yAxisDivisions) must be larger than 0'),
        super(key: key);

  final Enum? canDragCoordinateType;

  final Map<Enum, CoordinateStyle>? coordinateStyles;

  /// 点集
  final List<Coordinate<Enum>> allCoordinates;

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

  /// 左下边距
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
  final Color? defaultCoordinatePointColor;

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

  final CanDragCoordinatesValueCallback? onChange;

  final CanDragCoordinatesValueCallback? onChangeEnd;

  @override
  State<FlutterLineChart<Enum>> createState() => _FlutterLineChartState<Enum>();
}

class _FlutterLineChartState<Enum> extends State<FlutterLineChart<Enum>> {
  CoordinateStyle? getCoordinateStyleByType(Enum type) =>
      widget.coordinateStyles?[type];

  Coordinate<Enum>? _currentSelectedCoordinate;

  bool get hasCanDragCoordinates => canDragCoordinates != null;

  List<Coordinate<Enum>>? get canDragCoordinates {
    if (widget.canDragCoordinateType == null) {
      return null;
    }

    return coordinatesGroup.firstWhereOrNull((coordinates) =>
        coordinates.first.type == widget.canDragCoordinateType);
  }

  List<List<Coordinate<Enum>>> get otherCoordinatesGroup => coordinatesGroup
      .where((coordinates) =>
          coordinates.first.type != widget.canDragCoordinateType)
      .toList();

  List<double>? get currentCanDragCoordinatesValue =>
      canDragCoordinates?.map((coordinate) => coordinate.currentValue).toList();

  /// 反向平移[dx]以抵消[CoordinateSystemPainter]中[canvas]的平移
  double _reverseTranslateX(double dx) => dx - widget.marginLeftBottom;

  /// 反向平移[dy]以抵消[CoordinateSystemPainter]中[canvas]的平移
  double _reverseTranslateY(
    double dy, {
    required double chartHeight,
  }) =>
      dy - chartHeight + widget.marginLeftBottom;

  /// 调整[localPosition]
  Offset adjustLocalPosition(
    Offset localPosition, {
    required double chartHeight,
  }) =>
      Offset(
        _reverseTranslateX(localPosition.dx),
        _reverseTranslateY(
          localPosition.dy,
          chartHeight: chartHeight,
        ),
      );

  /// 获取X轴均分后的偏移值
  double getXAxisScaleOffsetValue(double chartWidth) =>
      (chartWidth - widget.marginLeftBottom) / widget.xAxis.length;

  /// 获取Y轴均分后的偏移值
  double getYAxisScaleOffsetValue(double chartHeight) =>
      (chartHeight - widget.marginLeftBottom) /
      (widget.yAxisMaxValue - widget.yAxisMinValue);

  /// 获取拖动范围内的Y轴偏移值
  double getYAxisOffsetValueWithinDragRange(
    double dy, {
    required double chartHeight,
    required double yAxisScaleOffsetValue,
    int yAxisDivisions = 1,
  }) {
    double offset =
        (_reverseTranslateY(dy, chartHeight: chartHeight) / yAxisDivisions)
            .clamp(
              _reverseTranslateY(0, chartHeight: chartHeight) / yAxisDivisions,
              0,
            )
            .floorToDouble();

    if (widget.enforceStepOffset) {
      if (widget.reversedYAxis) {
        offset -= widget.yAxisMinValue * yAxisScaleOffsetValue;
      } else {
        offset += widget.yAxisMinValue * yAxisScaleOffsetValue;
      }
    }

    return offset;
  }

  double currentValue2YAxisOffsetValue(
    double currentValue, {
    required double chartHeight,
    required double yAxisScaleOffsetValue,
    int yAxisDivisions = 1,
  }) =>
      (widget.reversedYAxis
          ? _reverseTranslateY(
              currentValue * yAxisScaleOffsetValue,
              chartHeight: chartHeight,
            )
          : -currentValue * yAxisScaleOffsetValue) *
      yAxisDivisions;

  double yAxisOffsetValue2CurrentValue(
    double yOffset, {
    required double yAxisScaleOffsetValue,
  }) =>
      (widget.reversedYAxis
              ? yOffset / yAxisScaleOffsetValue + widget.yAxisMaxValue
              : widget.yAxisMinValue - yOffset / yAxisScaleOffsetValue)
          .roundToDouble();

  Coordinate<Enum>? hintTestCoordinate(Offset position) => canDragCoordinates
      ?.firstWhereOrNull((coordinate) => coordinate.hintTest(position));

  /// Y轴值
  late List<int> yAxis;

  late List<List<Coordinate<Enum>>> coordinatesGroup;

  bool _allCoordinatesOffsetsUninitialized = true;

  void resetAllCoordinatesOffsetsInitializedStatus() {
    _allCoordinatesOffsetsUninitialized = true;
  }

  void allCoordinatesOffsetsInitializationCompleted() {
    _allCoordinatesOffsetsUninitialized = false;
  }

  void _initialYAxis() {
    yAxis = List.generate(
        (widget.yAxisMaxValue - widget.yAxisMinValue) ~/ widget.yAxisDivisions,
        (int index) =>
            widget.yAxisMinValue + index * widget.yAxisDivisions).toList();

    if (widget.reversedYAxis) {
      yAxis = yAxis.reversed.toList();
    }
  }

  void _initialCoordinatesGroup() {
    coordinatesGroup = widget.allCoordinates
        .fold<Map<Enum, List<Coordinate<Enum>>>>(
          <Enum, List<Coordinate<Enum>>>{},
          (previousValue, coordinate) {
            if (previousValue.containsKey(coordinate.type)) {
              previousValue[coordinate.type]!.add(coordinate);
            } else {
              previousValue[coordinate.type] = [coordinate];
            }

            return previousValue;
          },
        )
        .values
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _initialYAxis();

    _initialCoordinatesGroup();
  }

  @override
  void didUpdateWidget(covariant FlutterLineChart<Enum> oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool markRebuild = false;

    if (oldWidget.canDragCoordinateType != widget.canDragCoordinateType) {
      markRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.yAxisMaxValue != widget.yAxisMaxValue ||
        oldWidget.yAxisMinValue != widget.yAxisMinValue ||
        oldWidget.yAxisDivisions != widget.yAxisDivisions) {
      _initialYAxis();

      markRebuild = true;
    }

    if (oldWidget.allCoordinates
            .map((coordinates) => coordinates.hashCode)
            .join() !=
        widget.allCoordinates
            .map((coordinates) => coordinates.hashCode)
            .join()) {
      _initialCoordinatesGroup();

      resetAllCoordinatesOffsetsInitializedStatus();

      markRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.marginLeftBottom != widget.marginLeftBottom) {
      resetAllCoordinatesOffsetsInitializedStatus();

      markRebuild = true;
    }

    if (oldWidget.onlyRenderEvenYAxisText != widget.onlyRenderEvenYAxisText ||
        oldWidget.linkLineWidth != widget.linkLineWidth ||
        oldWidget.axisTextStyle != widget.axisTextStyle ||
        oldWidget.axisLineColor != widget.axisLineColor ||
        oldWidget.gridLineColor != widget.gridLineColor ||
        oldWidget.defaultCoordinatePointColor !=
            widget.defaultCoordinatePointColor ||
        oldWidget.defaultLinkLineColor != widget.defaultLinkLineColor ||
        oldWidget.defaultFillAreaColor != widget.defaultFillAreaColor ||
        oldWidget.coordinateStyles.hashCode !=
            widget.coordinateStyles.hashCode ||
        oldWidget.tapAreaColor != widget.tapAreaColor ||
        oldWidget.enforceStepOffset != widget.enforceStepOffset ||
        oldWidget.showTapArea != widget.showTapArea) {
      markRebuild = true;
    }

    if (_currentSelectedCoordinate != null &&
        !widget.allCoordinates.contains(_currentSelectedCoordinate)) {
      _currentSelectedCoordinate = widget.allCoordinates.firstWhereOrNull(
          (coordinate) => coordinate.id == _currentSelectedCoordinate!.id);
    }

    if (markRebuild) {
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
            _currentSelectedCoordinate = hintTestCoordinate(
              adjustLocalPosition(
                details.localPosition,
                chartHeight: chartHeight,
              ),
            );

            if (_currentSelectedCoordinate != null) {
              HapticFeedback.mediumImpact();
            }
          },
          onVerticalDragStart: (DragStartDetails details) {
            _currentSelectedCoordinate ??= hintTestCoordinate(
              adjustLocalPosition(
                details.localPosition,
                chartHeight: chartHeight,
              ),
            );
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (_currentSelectedCoordinate != null) {
              late double dy;

              final double yAxisScaleOffsetValue =
                  getYAxisScaleOffsetValue(chartHeight);

              if (widget.enforceStepOffset) {
                dy = getYAxisOffsetValueWithinDragRange(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yAxisScaleOffsetValue: yAxisScaleOffsetValue,
                  yAxisDivisions: widget.yAxisDivisions,
                );

                final double currentValue = yAxisOffsetValue2CurrentValue(
                  dy,
                  yAxisScaleOffsetValue: yAxisScaleOffsetValue,
                );

                dy = currentValue2YAxisOffsetValue(
                  currentValue,
                  chartHeight: chartHeight,
                  yAxisScaleOffsetValue: yAxisScaleOffsetValue,
                  yAxisDivisions: widget.yAxisDivisions,
                );
              } else {
                dy = getYAxisOffsetValueWithinDragRange(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yAxisScaleOffsetValue: yAxisScaleOffsetValue,
                );
              }

              _currentSelectedCoordinate!.offset = Offset(
                _currentSelectedCoordinate!.offset.dx,
                dy,
              );

              setState(() {});

              if (currentCanDragCoordinatesValue != null) {
                widget.onChange?.call(currentCanDragCoordinatesValue!);
              }
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {
            _currentSelectedCoordinate = null;

            if (currentCanDragCoordinatesValue != null) {
              widget.onChangeEnd?.call(currentCanDragCoordinatesValue!);
            }
          },
          onVerticalDragCancel: () {
            _currentSelectedCoordinate = null;
          },
          child: CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: CoordinateSystemPainter<Enum>(
              coordinatesGroup: coordinatesGroup,
              allCoordinatesOffsetsUninitialized:
                  _allCoordinatesOffsetsUninitialized,
              otherCoordinatesGroup: otherCoordinatesGroup,
              hasCanDragCoordinates: hasCanDragCoordinates,
              canDragCoordinates: canDragCoordinates,
              xAxis: widget.xAxis,
              yAxis: yAxis,
              yAxisDivisions: widget.yAxisDivisions,
              yAxisMaxValue: widget.yAxisMaxValue,
              yAxisMinValue: widget.yAxisMinValue,
              reversedYAxis: widget.reversedYAxis,
              onlyRenderEvenYAxisText: widget.onlyRenderEvenYAxisText,
              marginLeftBottom: widget.marginLeftBottom,
              linkLineWidth: widget.linkLineWidth,
              axisTextStyle: widget.axisTextStyle,
              axisLineColor: widget.axisLineColor,
              gridLineColor: widget.gridLineColor,
              defaultAxisPointColor: widget.defaultCoordinatePointColor,
              defaultLinkLineColor: widget.defaultLinkLineColor,
              defaultFillAreaColor: widget.defaultFillAreaColor,
              tapAreaColor: widget.tapAreaColor,
              enforceStepOffset: widget.enforceStepOffset,
              showTapArea: widget.showTapArea,
              drawCheckOrClose: widget.drawCheckOrClose,
              allCoordinatesOffsetsInitializationCompleted:
                  allCoordinatesOffsetsInitializationCompleted,
              getCoordinateStyleByType: getCoordinateStyleByType,
              adjustLocalPosition: adjustLocalPosition,
              getXAxisScaleOffsetValue: getXAxisScaleOffsetValue,
              getYAxisScaleOffsetValue: getYAxisScaleOffsetValue,
              getYAxisOffsetValueWithinDragRange:
                  getYAxisOffsetValueWithinDragRange,
              currentValue2YAxisOffsetValue: currentValue2YAxisOffsetValue,
              yAxisOffsetValue2CurrentValue: yAxisOffsetValue2CurrentValue,
            ),
          ),
        );
      },
    );
  }
}
