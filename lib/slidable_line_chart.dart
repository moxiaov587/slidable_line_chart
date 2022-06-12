library slidable_line_chart;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'coordinate_system_painter.dart';
import 'model/coordinate.dart';

export 'model/coordinate.dart';

typedef CanDragCoordinatesValueCallback = void Function(
    List<double> canDragCoordinatesValue);

class SlidableLineChart<Enum> extends StatefulWidget {
  const SlidableLineChart({
    Key? key,
    this.canDragCoordinateType,
    required this.allCoordinates,
    required this.xAxis,
    required this.yAxisDivisions,
    required this.yAxisMaxValue,
    required this.yAxisMinValue,
    this.reversedYAxis = false,
    this.onlyRenderEvenYAxisText = true,
    this.coordinateSystemOrigin = const Offset(6.0, 6.0),
    this.enableInitializationAnimation = true,
    this.initializationAnimationDuration = const Duration(milliseconds: 1200),
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
  ///
  /// 会根据该值和[yAxisMaxValue], [yAxisDivisions]来生成Y轴
  ///
  /// 该值也是用户可以拖动到的最小值
  ///
  /// Y轴生成还受[reversedYAxis], [onlyRenderEvenYAxisText]影响
  /// 详见[_generateYAxis]
  final int yAxisMinValue;

  /// Y轴最大值
  ///
  /// 会根据该值和[yAxisMinValue], [yAxisDivisions]来生成Y轴
  ///
  /// 该值也是用户可以拖动到的最大值
  ///
  /// Y轴生成还受[reversedYAxis], [onlyRenderEvenYAxisText]影响
  /// 详见[_generateYAxis]
  final int yAxisMaxValue;

  /// Y轴分隔值
  ///
  /// 会根据该值和[yAxisMinValue], [yAxisMaxValue]来生成Y轴
  ///
  /// 该值也是开启强制步进偏移(`enforceStepOffset`)时的步进值
  final int yAxisDivisions;

  /// 反转Y轴
  final bool reversedYAxis;

  /// 只渲染偶数项的Y轴文本
  final bool onlyRenderEvenYAxisText;

  /// 坐标系原点
  final Offset coordinateSystemOrigin;

  /// 启用图表初始化动画
  final bool enableInitializationAnimation;

  /// 图表初始化动画时长
  final Duration initializationAnimationDuration;

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
  State<SlidableLineChart<Enum>> createState() =>
      _SlidableLineChartState<Enum>();
}

class _SlidableLineChartState<Enum> extends State<SlidableLineChart<Enum>>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  CoordinateStyle? getCoordinateStyleByType(Enum type) =>
      widget.coordinateStyles?[type];

  Coordinate<Enum>? _currentSelectedCoordinate;

  bool get hasCanDragCoordinates => canDragCoordinates != null;

  List<Coordinate<Enum>>? get canDragCoordinates {
    if (widget.canDragCoordinateType == null) {
      return null;
    }

    return coordinatesGroup.firstWhereOrNull(
        (List<Coordinate<Enum>> coordinates) =>
            coordinates.first.type == widget.canDragCoordinateType);
  }

  List<List<Coordinate<Enum>>> get otherCoordinatesGroup => coordinatesGroup
      .where((List<Coordinate<Enum>> coordinates) =>
          coordinates.first.type != widget.canDragCoordinateType)
      .toList();

  List<double>? get currentCanDragCoordinatesValue => canDragCoordinates
      ?.map((Coordinate<Enum> coordinate) => coordinate.currentValue)
      .toList();

  /// 反向偏移[dx]以抵消坐标系原点(`coordinateSystemOrigin`)的偏移
  double _reverseTranslateX(double dx) => dx - widget.coordinateSystemOrigin.dx;

  /// 反向偏移[dy]以抵消坐标系原点(`coordinateSystemOrigin`)的偏移
  double _reverseTranslateY(
    double dy, {
    required double chartHeight,
  }) =>
      dy - chartHeight + widget.coordinateSystemOrigin.dy;

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
  ///
  /// 需要减去坐标系原点(`coordinateSystemOrigin`)偏移的[dx]
  double getXAxisScaleOffsetValue(double chartWidth) =>
      (chartWidth - widget.coordinateSystemOrigin.dx) / widget.xAxis.length;

  /// 获取Y轴均分后的偏移值
  ///
  /// 需要减去坐标系原点(`coordinateSystemOrigin`)偏移的[dy]
  double getYAxisScaleOffsetValue(double chartHeight) =>
      (chartHeight - widget.coordinateSystemOrigin.dy) / (yAxis.length - 1);

  /// 获取经过[_generateYAxis]处理后的Y轴实际最大值
  ///
  /// 当[reversedYAxis]为true时是Y轴第一项
  /// 否则是Y轴最后一项
  int get realYAxisMaxValue => widget.reversedYAxis ? yAxis.first : yAxis.last;

  /// Y轴实际最大值与限制最大值的差
  ///
  /// 用于限制拖动范围
  int get yAxisMaxValueDifference => realYAxisMaxValue - widget.yAxisMaxValue;

  /// Y轴实际最大值占据坐标网格数
  ///
  /// 用于限制开启强制步进偏移(`enforceStepOffset`)时
  /// 特殊场景下的最大值
  double get realYAxisMaxNumberOfGridsOccupied =>
      ((widget.yAxisMaxValue - widget.yAxisMinValue) /
          (realYAxisMaxValue - widget.yAxisMinValue)) *
      (yAxis.length - 1);

  /// 获取Y轴真实值到偏移值的转换系数
  double getYAxisRealValue2OffsetValueFactor(double chartHeight) =>
      (chartHeight - widget.coordinateSystemOrigin.dy) /
      (realYAxisMaxValue - widget.yAxisMinValue);

  /// 获取拖动范围内的Y轴偏移值
  double getYAxisOffsetValueWithinDragRange(
    double dy, {
    required double chartHeight,
    required double yAxisRealValue2OffsetValueFactor,
    int yAxisDivisions = 1,
  }) {
    double yAxisOffsetValue = _reverseTranslateY(
          widget.reversedYAxis
              ? dy.clamp(
                  0,
                  chartHeight -
                      widget.coordinateSystemOrigin.dy -
                      yAxisMaxValueDifference *
                          yAxisRealValue2OffsetValueFactor,
                )
              : dy.clamp(
                  yAxisMaxValueDifference * yAxisRealValue2OffsetValueFactor,
                  chartHeight - widget.coordinateSystemOrigin.dy,
                ),
          chartHeight: chartHeight,
        ) /
        yAxisDivisions;

    if (widget.enforceStepOffset) {
      if (widget.reversedYAxis) {
        yAxisOffsetValue -=
            widget.yAxisMinValue * yAxisRealValue2OffsetValueFactor;
      } else {
        yAxisOffsetValue +=
            widget.yAxisMinValue * yAxisRealValue2OffsetValueFactor;
      }
    }

    return yAxisOffsetValue;
  }

  double currentValue2YAxisOffsetValue(
    double currentValue, {
    required double chartHeight,
    required double yAxisRealValue2OffsetValueFactor,
    int yAxisDivisions = 1,
  }) =>
      (widget.reversedYAxis
          ? _reverseTranslateY(
              currentValue * yAxisRealValue2OffsetValueFactor,
              chartHeight: chartHeight,
            )
          : -currentValue * yAxisRealValue2OffsetValueFactor) *
      yAxisDivisions;

  double yAxisOffsetValue2CurrentValue(
    double yAxisOffsetValue, {
    required double yAxisRealValue2OffsetValueFactor,
  }) =>
      widget.reversedYAxis
          ? realYAxisMaxValue +
              yAxisOffsetValue / yAxisRealValue2OffsetValueFactor
          : widget.yAxisMinValue -
              yAxisOffsetValue / yAxisRealValue2OffsetValueFactor;

  /// 保留上下界执行[round]和[clamp]
  double _keepBoundaryToRoundAndClamp(
    double min,
    double max, {
    required double value,
  }) {
    if (value != min && value != max) {
      value = value.roundToDouble();
    }

    return value.clamp(min, max);
  }

  double generateEnforceStepYAxisOffsetValue(
    double dy, {
    required double chartHeight,
    required double yAxisRealValue2OffsetValueFactor,
  }) {
    final double yAxisOffsetValue = getYAxisOffsetValueWithinDragRange(
      dy,
      chartHeight: chartHeight,
      yAxisRealValue2OffsetValueFactor: yAxisRealValue2OffsetValueFactor,
      yAxisDivisions: widget.yAxisDivisions, // 除以分隔值
    );

    double currentValue = yAxisOffsetValue2CurrentValue(
      yAxisOffsetValue,
      yAxisRealValue2OffsetValueFactor: yAxisRealValue2OffsetValueFactor,
    );

    if (widget.reversedYAxis) {
      final double min = yAxisOffsetValue2CurrentValue(
        getYAxisOffsetValueWithinDragRange(
          widget.coordinateSystemOrigin.dy +
              yAxisMaxValueDifference * yAxisRealValue2OffsetValueFactor -
              chartHeight,
          chartHeight: chartHeight,
          yAxisRealValue2OffsetValueFactor: yAxisRealValue2OffsetValueFactor,
          yAxisDivisions: widget.yAxisDivisions,
        ),
        yAxisRealValue2OffsetValueFactor: yAxisRealValue2OffsetValueFactor,
      );

      final double max = min + realYAxisMaxNumberOfGridsOccupied;

      currentValue = _keepBoundaryToRoundAndClamp(
        min,
        max,
        value: currentValue,
      );
    } else {
      currentValue = _keepBoundaryToRoundAndClamp(
        0,
        realYAxisMaxNumberOfGridsOccupied,
        value: currentValue,
      );
    }

    return currentValue2YAxisOffsetValue(
      currentValue,
      chartHeight: chartHeight,
      yAxisRealValue2OffsetValueFactor: yAxisRealValue2OffsetValueFactor,
      yAxisDivisions: widget.yAxisDivisions, // 乘以分隔值
    );
  }

  Coordinate<Enum>? hitTestCoordinate(Offset position) =>
      canDragCoordinates?.firstWhereOrNull(
          (Coordinate<Enum> coordinate) => coordinate.hitTest(position));

  /// Y轴值
  late List<int> yAxis;

  late List<List<Coordinate<Enum>>> coordinatesGroup;

  /// 所有坐标点(`allCoordinates`)的[offset]值未初始化
  ///
  /// 用以标识绘制时坐标点[offset]值的初始化完成状态
  /// 避免重复初始化
  bool _allCoordinatesOffsetsUninitialized = true;

  /// 重置坐标点的初始化状态
  void resetAllCoordinatesOffsetsInitializedStatus() {
    _allCoordinatesOffsetsUninitialized = true;

    _animationController?.reset();
  }

  /// 标识坐标点初始化完成
  void allCoordinatesOffsetsInitializationCompleted() {
    _allCoordinatesOffsetsUninitialized = false;

    _animationController?.forward();
  }

  /// 生成[yAxis]
  ///
  /// 每个图表只需要生成一次
  ///
  /// 当`reversedYAxis`, `yAxisMaxValue`, `yAxisMinValue`
  /// 和`onlyRenderEvenYAxisText`任一值改变时需要重新生成
  ///
  /// 当指定最大值(`yAxisMaxValue`)大于当前数组的最后一项时
  /// 即最大值未包含在即将生成的数组内, 需使长度+1
  ///
  /// 当开启只渲染偶数行(`onlyRenderEvenYAxisText`)
  /// 且即将生成的数组长度为偶数时, 需使长度+1
  void _generateYAxis() {
    int yAxisLength =
        ((widget.yAxisMaxValue - widget.yAxisMinValue) / widget.yAxisDivisions)
            .ceil();

    if (widget.yAxisMaxValue >
        widget.yAxisMinValue + (yAxisLength - 1) * widget.yAxisDivisions) {
      yAxisLength += 1;
    }

    if (widget.onlyRenderEvenYAxisText && yAxisLength.isEven) {
      yAxisLength += 1;
    }

    yAxis = List<int>.generate(
      yAxisLength,
      (int index) => widget.yAxisMinValue + index * widget.yAxisDivisions,
      growable: false,
    ).toList();

    if (widget.reversedYAxis) {
      yAxis = yAxis.reversed.toList();
    }
  }

  /// 生成[coordinatesGroup]
  ///
  /// 每个图表只需要生成一次
  ///
  /// 仅有当`allCoordinates`改变时需要重新生成
  void _generateCoordinatesGroup() {
    coordinatesGroup = widget.allCoordinates
        .fold<Map<Enum, List<Coordinate<Enum>>>>(
          <Enum, List<Coordinate<Enum>>>{},
          (Map<Enum, List<Coordinate<Enum>>> coordinatesGroupMap,
              Coordinate<Enum> coordinate) {
            if (coordinatesGroupMap.containsKey(coordinate.type)) {
              coordinatesGroupMap[coordinate.type]!.add(coordinate);
            } else {
              coordinatesGroupMap[coordinate.type] = <Coordinate<Enum>>[
                coordinate
              ];
            }

            return coordinatesGroupMap;
          },
        )
        .values
        .toList();
  }

  void _initializationAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.initializationAnimationDuration,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.enableInitializationAnimation) {
      _initializationAnimationController();
    }

    _generateYAxis();

    _generateCoordinatesGroup();
  }

  @override
  void didUpdateWidget(covariant SlidableLineChart<Enum> oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool markRebuild = false;

    if (oldWidget.canDragCoordinateType != widget.canDragCoordinateType) {
      markRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.yAxisMaxValue != widget.yAxisMaxValue ||
        oldWidget.yAxisMinValue != widget.yAxisMinValue ||
        oldWidget.yAxisDivisions != widget.yAxisDivisions) {
      _generateYAxis();

      markRebuild = true;
    }

    if (oldWidget.allCoordinates
            .map((Coordinate<Enum> coordinates) => coordinates.hashCode)
            .join() !=
        widget.allCoordinates
            .map((Coordinate<Enum> coordinates) => coordinates.hashCode)
            .join()) {
      _generateCoordinatesGroup();

      resetAllCoordinatesOffsetsInitializedStatus();

      markRebuild = true;
    }

    if (oldWidget.reversedYAxis != widget.reversedYAxis ||
        oldWidget.coordinateSystemOrigin != widget.coordinateSystemOrigin) {
      resetAllCoordinatesOffsetsInitializedStatus();

      markRebuild = true;
    }

    if (oldWidget.onlyRenderEvenYAxisText != widget.onlyRenderEvenYAxisText) {
      _generateYAxis();

      resetAllCoordinatesOffsetsInitializedStatus();

      markRebuild = true;
    }

    if (oldWidget.enableInitializationAnimation !=
            widget.enableInitializationAnimation ||
        oldWidget.initializationAnimationDuration !=
            widget.initializationAnimationDuration) {
      if (widget.enableInitializationAnimation) {
        _initializationAnimationController();

        resetAllCoordinatesOffsetsInitializedStatus();
      } else {
        _animationController?.dispose();

        _animationController = null;
      }

      markRebuild = true;
    }

    if (oldWidget.linkLineWidth != widget.linkLineWidth ||
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
          (Coordinate<Enum> coordinate) =>
              coordinate.id == _currentSelectedCoordinate!.id);
    }

    if (markRebuild) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        final Widget coordinateSystemPainter = CustomPaint(
          size: Size(chartWidth, chartHeight),
          painter: CoordinateSystemPainter<Enum>(
            animationController: _animationController,
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
            coordinateSystemOrigin: widget.coordinateSystemOrigin,
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
            getYAxisRealValue2OffsetValueFactor:
                getYAxisRealValue2OffsetValueFactor,
            getYAxisOffsetValueWithinDragRange:
                getYAxisOffsetValueWithinDragRange,
            currentValue2YAxisOffsetValue: currentValue2YAxisOffsetValue,
            yAxisOffsetValue2CurrentValue: yAxisOffsetValue2CurrentValue,
          ),
        );

        if (hasCanDragCoordinates) {
          return GestureDetector(
            onVerticalDragDown: (DragDownDetails details) {
              _currentSelectedCoordinate = hitTestCoordinate(
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
              _currentSelectedCoordinate ??= hitTestCoordinate(
                adjustLocalPosition(
                  details.localPosition,
                  chartHeight: chartHeight,
                ),
              );
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              if (_currentSelectedCoordinate != null) {
                late double dy;

                final double yAxisRealValue2OffsetValueFactor =
                    getYAxisRealValue2OffsetValueFactor(chartHeight);

                if (widget.enforceStepOffset) {
                  dy = generateEnforceStepYAxisOffsetValue(
                    details.localPosition.dy,
                    chartHeight: chartHeight,
                    yAxisRealValue2OffsetValueFactor:
                        yAxisRealValue2OffsetValueFactor,
                  );
                } else {
                  dy = getYAxisOffsetValueWithinDragRange(
                    details.localPosition.dy,
                    chartHeight: chartHeight,
                    yAxisRealValue2OffsetValueFactor:
                        yAxisRealValue2OffsetValueFactor,
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
            child: coordinateSystemPainter,
          );
        }

        return coordinateSystemPainter;
      },
    );
  }
}
