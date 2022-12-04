library slidable_line_chart;

import 'package:collection/collection.dart' show IterableExtension;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'coordinate_system_painter.dart';
import 'model/coordinates_options.dart';
import 'theme/slidable_line_chart_theme.dart';

export 'model/coordinates_options.dart' show CoordinatesOptions;
export 'theme/slidable_line_chart_theme.dart';

typedef CoordinatesOptionsChanged<Enum> = void Function(
    List<CoordinatesOptions<Enum>> options);

class SlidableLineChart<Enum> extends StatefulWidget {
  const SlidableLineChart({
    Key? key,
    this.slidableCoordinateType,
    required this.coordinatesOptionsList,
    required this.xAxis,
    required this.min,
    required this.max,
    this.coordinateSystemOrigin = const Offset(6.0, 6.0),
    this.divisions = 1,
    this.slidePrecision,
    this.reversed = false,
    this.onlyRenderEvenAxisLabel = true,
    this.enableInitializationAnimation = true,
    this.initializationAnimationDuration = const Duration(seconds: 1),
    this.onDrawCheckOrClose,
    this.onChange,
    this.onChangeStart,
    this.onChangeEnd,
  })  : assert(max > min, 'max($max) must be larger than min($min)'),
        assert(divisions > 0 && divisions <= max - min,
            'divisions($divisions) must be larger than 0 and less than max - min'),
        assert(slidePrecision == null || (slidePrecision * 100) % 1 == 0,
            'slidePrecision($slidePrecision) must be a multiple of 0.01.'),
        super(key: key);

  /// The type of coordinates the user can slide.
  ///
  /// Defaults to null.
  final Enum? slidableCoordinateType;

  /// An array contain coordinates configuration information.
  ///
  /// use [SlidableLineChartState.build] generates
  /// [SlidableLineChartState._coordinatesMap].
  final List<CoordinatesOptions<Enum>> coordinatesOptionsList;

  /// Labels displayed on the x-axis.
  final List<String> xAxis;

  /// Coordinate system origin offset value.
  ///
  /// Defaults to Offset(6.0, 6.0).
  final Offset coordinateSystemOrigin;

  /// The minimum value that the user can slide to.
  ///
  /// Must be less than or equal to [max].
  ///
  /// Generate [SlidableLineChartState._yAxis] from this value and
  /// [max], [divisions].
  ///
  /// This value is also the start value for the Y-axis.
  ///
  /// Y-axis generate is also affected by [reversed] and [onlyRenderEvenAxisLabel],
  /// See [SlidableLineChartState._generateYAxis].
  final int min;

  /// The maximum value that the user can slide to.
  ///
  /// Must be greater than or equal to [min].
  ///
  /// Generate [SlidableLineChartState._yAxis] from this value and
  /// [min], [divisions].
  ///
  /// This value is not necessarily the maximum value actually display on the Y-axis.
  ///
  /// Y-axis generation is also affected by [reversed] and [onlyRenderEvenAxisLabel],
  /// See [SlidableLineChartState._generateYAxis].
  final int max;

  /// The division value of y-axis.
  ///
  /// Defaults to 1. Must be less than or equal to 0.
  ///
  /// Generate [SlidableLineChartState._yAxis] from this value and
  /// [min], [max].
  final int divisions;

  /// The minimum value for each slide by the user.
  ///
  /// Must be a multiple of 0.01.
  ///
  /// If this value are null, then [divisions] will be used.
  final double? slidePrecision;

  /// Whether the coordinate system is reversed.
  ///
  /// Defaults to false.
  ///
  /// This value affects the generation of the Y-axis.
  /// See [SlidableLineChartState._generateYAxis].
  final bool reversed;

  /// Whether the y-axis label renders only even items.
  ///
  /// Defaults to true.
  ///
  /// This value affects the generation of the Y-axis.
  /// See [SlidableLineChartState._generateYAxis].
  final bool onlyRenderEvenAxisLabel;

  /// Whether the coordinate system triggers animation when initialized.
  ///
  /// Defaults to true.
  final bool enableInitializationAnimation;

  /// Initialize the duration of the animation.
  ///
  /// Defaults to Duration(seconds: 1).
  final Duration initializationAnimationDuration;

  /// Called when the user slides coordinate, the return value determines the
  /// indicator type.
  ///
  /// The return value is used to draw a check or close indicator
  /// below the coordinate system.
  ///
  /// Defaults to null, nothing.
  ///
  /// See [CoordinateSystemPainter.drawCoordinates].
  final OnDrawIndicator? onDrawCheckOrClose;

  /// Called when the user slides coordinate.
  ///
  /// The coordinate passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the chart with the new value.
  ///
  /// If null, the chart will be displayed as disabled.
  ///
  /// See also:
  ///
  /// * [onChangeStart] for a callback that is called when the user starts
  ///    sliding the coordinate.
  /// * [onChangeEnd] for a callback that is called when the user stops
  ///    sliding the coordinate.
  final CoordinatesOptionsChanged<Enum>? onChange;

  /// Called when the user starts sliding coordinate.
  ///
  /// See also:
  ///
  /// * [onChangeEnd] for a callback that is called when the user stops
  ///    sliding the coordinate.
  final CoordinatesOptionsChanged<Enum>? onChangeStart;

  /// Called when the user stops sliding coordinate.
  ///
  /// See also:
  ///
  /// * [onChangeStart] for a callback that is called when the user starts
  ///    sliding the coordinate.
  final CoordinatesOptionsChanged<Enum>? onChangeEnd;

  @override
  State<SlidableLineChart<Enum>> createState() =>
      SlidableLineChartState<Enum>();
}

class SlidableLineChartState<Enum> extends State<SlidableLineChart<Enum>>
    with TickerProviderStateMixin {
  AnimationController? _slidableCoordinatesAnimationController;

  AnimationController? _otherCoordinatesAnimationController;

  /// The index of the current sliding coordinate.
  int? _currentSlideCoordinateIndex;

  num get _slidePrecision => widget.slidePrecision ?? widget.divisions;

  /// Slidable coordinates.
  ///
  /// Null when [SlidableLineChart.slidableCoordinateType] is null.
  Coordinates<Enum>? get _slidableCoordinates =>
      _coordinatesMap[widget.slidableCoordinateType];

  /// Get X-axis tick line width from the length of [SlidableLineChart.xAxis].
  ///
  /// Calculate by subtracting `dx` from [SlidableLineChart.coordinateSystemOrigin].
  ///
  /// This value divided by 2 is dx for the coordinate offset.
  double _getXAxisTickLineWidth(double chartActualWidth) =>
      chartActualWidth / widget.xAxis.length;

  /// Get Y-axis tick line height from the length of [_yAxis].
  ///
  /// Calculate by subtracting `dy` from [SlidableLineChart.coordinateSystemOrigin].
  double _getYAxisTickLineHeight(double chartActualHeight) =>
      chartActualHeight / (_yAxis.length - 1);

  /// Maximum Y-axis value after [_generateYAxis] processing.
  ///
  /// If [SlidableLineChart.reversed] is true, that first item in [_yAxis],
  /// otherwise it is the last item.
  ///
  /// See [_generateYAxis].
  late int _yAxisMaxValue;

  /// Percentage of the coordinate system outside the sliding area.
  ///
  /// Derived area due to [SlidableLineChart.max] and [SlidableLineChart.onlyRenderEvenAxisLabel]
  /// effects.
  ///
  /// Used to limit the range offset values the user can slide.
  ///
  /// See [_generateYAxis].
  late double _percentDerivedArea;

  /// The number of rows the derived region occupies on the Y-axis.
  ///
  /// See [_generateYAxis].
  late double _numberOfRowsOnDerivedArea;

  /// Minimum number of logical rows in the sliding area.
  ///
  /// When [SlidableLineChart.divisions] is 1 and [_slidePrecision] is 0.1,
  /// `Logic rows number` should be 10, i.e. [SlidableLineChart.divisions] / [_slidePrecision].
  ///
  /// Used to limit the range number of logical rows the user can slide.
  ///
  /// See [_generateMinAndMaxValuesForNumberOfLogicRowsOnYAxisSlidingArea].
  late double _minLogicRowsNumberOnSlidingArea;

  /// Maximum number of logical rows in the sliding area.
  ///
  /// When [SlidableLineChart.divisions] is 1 and [_slidePrecision] is 0.1,
  /// `Logic rows number` should be 10, i.e. [SlidableLineChart.divisions] / [_slidePrecision].
  ///
  /// Used to limit the range number of logical rows the user can slide.
  ///
  /// See [_generateMinAndMaxValuesForNumberOfLogicRowsOnYAxisSlidingArea].
  late double _maxLogicRowsNumberOnSlidingArea;

  /// Get the conversion factor from the Y-axis display value to the offset value.
  ///
  /// `display value * this factor = offset value`.
  double _getYAxisDisplayValue2OffsetValueFactor(double chartActualHeight) =>
      chartActualHeight / (_yAxisMaxValue - widget.min);

  /// Display value to Y-axis offset value.
  double _displayValue2YAxisOffsetValue(
    double displayValue, {
    required double chartActualHeight,
    required double yAxisDisplayValue2OffsetValueFactor,
  }) =>
      widget.reversed
          ? (displayValue - widget.min) * yAxisDisplayValue2OffsetValueFactor
          : chartActualHeight -
              (displayValue - widget.min) * yAxisDisplayValue2OffsetValueFactor;

  double _keepBoundsRoundToDouble(
    double min,
    double max, {
    required double value,
  }) {
    if (value > min && value < max) {
      value = value.roundToDouble();
    }

    return value.clamp(min, max);
  }

  /// Get the value displayed on the y-axis at the current position according
  /// to the slide precision.
  double _getYAxisDisplayValueBySlidePrecision(
    double dy, {
    required double chartActualHeight,
    required double minOffsetValueForSlidingAreaOnYAxis,
    required double maxOffsetValueForSlidingAreaOnYAxis,
  }) {
    final double dyLogicRowsNumberOnSlidingArea = _keepBoundsRoundToDouble(
      _minLogicRowsNumberOnSlidingArea,
      _maxLogicRowsNumberOnSlidingArea,
      value: (dy.clamp(minOffsetValueForSlidingAreaOnYAxis,
                  maxOffsetValueForSlidingAreaOnYAxis) /
              (maxOffsetValueForSlidingAreaOnYAxis -
                  minOffsetValueForSlidingAreaOnYAxis)) *
          (_maxLogicRowsNumberOnSlidingArea - _minLogicRowsNumberOnSlidingArea),
    );

    late double result;

    if (widget.reversed) {
      result = dyLogicRowsNumberOnSlidingArea * _slidePrecision + widget.min;
    } else {
      result =
          _yAxisMaxValue - dyLogicRowsNumberOnSlidingArea * _slidePrecision;
    }

    return double.parse(
      result.toStringAsFixed(
        2,
      ), // Reduce calculation error and limit decimal place precision of display value.
    );
  }

  /// Return null when user does not select or [_slidableCoordinates] is null,
  /// otherwise return the `index` of [Coordinate] selected in [_slidableCoordinates].
  int? _hitTestCoordinate(Offset position) {
    final int? index = _slidableCoordinates?.value
        .indexWhere((Coordinate coordinate) => coordinate.hitTest(position));

    if (index == -1) {
      return null;
    }

    return index;
  }

  /// Text display on Y-axis.
  ///
  /// See [_generateYAxis].
  late List<int> _yAxis;

  /// [Map] containing all coordinates data.
  ///
  /// Generated by [SlidableLineChart.coordinatesOptionsList] and rendered later
  /// by modifying it.
  ///
  /// See [build].
  late Map<Enum, Coordinates<Enum>> _coordinatesMap;

  /// Generate minimum and maximum values for the number of logical rows on the
  /// y-Axis sliding area.
  ///
  /// When [SlidableLineChart.slidePrecision] will be regenerated when changes.
  void _generateMinAndMaxValuesForNumberOfLogicRowsOnYAxisSlidingArea([
    double? numberOfRowsDisplayedOnYAxis,
  ]) {
    numberOfRowsDisplayedOnYAxis ??= _yAxis.length - 1;

    if (widget.reversed) {
      _minLogicRowsNumberOnSlidingArea = 0.0;

      _maxLogicRowsNumberOnSlidingArea =
          (numberOfRowsDisplayedOnYAxis - _numberOfRowsOnDerivedArea) *
              widget.divisions /
              _slidePrecision;
    } else {
      _minLogicRowsNumberOnSlidingArea =
          _numberOfRowsOnDerivedArea * widget.divisions / _slidePrecision;

      _maxLogicRowsNumberOnSlidingArea =
          numberOfRowsDisplayedOnYAxis * widget.divisions / _slidePrecision;
    }
  }

  /// Generate Y-axis.
  ///
  /// When [SlidableLineChart.reversed], [SlidableLineChart.min], [SlidableLineChart.max],
  /// [SlidableLineChart.divisions] and [SlidableLineChart.onlyRenderEvenAxisLabel]
  /// will be regenerated when any value changes.
  ///
  /// If [SlidableLineChart.max] is greater than the last item in the current list,
  /// set the length to +1.
  ///
  /// If [SlidableLineChart.onlyRenderEvenAxisLabel] is true, and the current list
  /// length is even, set the length to +1.
  void _generateYAxis() {
    int yAxisLength = ((widget.max - widget.min) / widget.divisions).ceil();

    if (widget.max > widget.min + (yAxisLength - 1) * widget.divisions) {
      yAxisLength += 1;
    }

    if (widget.onlyRenderEvenAxisLabel && yAxisLength.isEven) {
      yAxisLength += 1;
    }

    _yAxis = List<int>.generate(
      yAxisLength,
      (int index) => widget.min + index * widget.divisions,
      growable: false,
    ).toList();

    _yAxisMaxValue = _yAxis.last;

    _percentDerivedArea =
        (_yAxisMaxValue - widget.max) / (_yAxis.last - _yAxis.first);

    final double numberOfRowsDisplayedOnYAxis = _yAxis.length - 1;

    _numberOfRowsOnDerivedArea =
        _percentDerivedArea * numberOfRowsDisplayedOnYAxis;

    if (widget.reversed) {
      _yAxis = _yAxis.reversed.toList();
    }

    _generateMinAndMaxValuesForNumberOfLogicRowsOnYAxisSlidingArea(
        numberOfRowsDisplayedOnYAxis);
  }

  void _initializationAnimationController() {
    _slidableCoordinatesAnimationController = AnimationController(
      vsync: this,
      duration: widget.initializationAnimationDuration,
    );

    _otherCoordinatesAnimationController = AnimationController(
      vsync: this,
      duration: widget.initializationAnimationDuration,
    );
  }

  /// Reset animation controllers to initial values.
  ///
  /// When [resetAll] is true, both [_slidableCoordinatesAnimationController] and
  /// [_otherCoordinatesAnimationController] are reset, otherwise only
  /// [_slidableCoordinatesAnimationController] is reset.
  ///
  /// By default, the initialization animation is executed only once.
  ///
  /// You can use this method to trigger the animation again when reversing,
  /// switching data sources, and resetting data to initial values.
  void resetAnimationController({bool resetAll = true}) {
    _slidableCoordinatesAnimationController?.reset();

    if (resetAll) {
      _otherCoordinatesAnimationController?.reset();
    }
  }

  void _forwardAnimationControllerWhenIsDismissed() {
    if (_slidableCoordinatesAnimationController?.isDismissed ?? false) {
      _slidableCoordinatesAnimationController?.forward();
    }

    if (_otherCoordinatesAnimationController?.isDismissed ?? false) {
      _otherCoordinatesAnimationController?.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.enableInitializationAnimation) {
      _initializationAnimationController();
    }

    _generateYAxis();
  }

  @override
  void didUpdateWidget(covariant SlidableLineChart<Enum> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reversed != widget.reversed ||
        oldWidget.max != widget.max ||
        oldWidget.min != widget.min ||
        oldWidget.divisions != widget.divisions ||
        oldWidget.onlyRenderEvenAxisLabel != widget.onlyRenderEvenAxisLabel) {
      _generateYAxis();
    }

    if (oldWidget.slidePrecision != widget.slidePrecision) {
      _generateMinAndMaxValuesForNumberOfLogicRowsOnYAxisSlidingArea();
    }

    if (oldWidget.enableInitializationAnimation !=
            widget.enableInitializationAnimation ||
        oldWidget.initializationAnimationDuration !=
            widget.initializationAnimationDuration) {
      if (widget.enableInitializationAnimation) {
        _initializationAnimationController();
      } else {
        _slidableCoordinatesAnimationController?.dispose();
        _slidableCoordinatesAnimationController = null;

        _otherCoordinatesAnimationController?.dispose();
        _otherCoordinatesAnimationController = null;
      }
    }
  }

  @override
  void dispose() {
    _slidableCoordinatesAnimationController?.dispose();
    _otherCoordinatesAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        if (chartWidth == 0.0 || chartHeight == 0.0) {
          return const SizedBox.shrink();
        }

        final double xAxisTickLineWidth = _getXAxisTickLineWidth(chartWidth);

        final double chartActualHeight =
            chartHeight - widget.coordinateSystemOrigin.dy;

        final double yAxisDisplayValue2OffsetValueFactor =
            _getYAxisDisplayValue2OffsetValueFactor(chartActualHeight);

        _coordinatesMap = <Enum, Coordinates<Enum>>{
          for (final CoordinatesOptions<Enum> options
              in widget.coordinatesOptionsList)
            options.type: Coordinates<Enum>(
              type: options.type,
              value: options.values
                  .mapIndexed(
                    (int index, double value) => Coordinate(
                      value: value,
                      offset: Offset(
                        (xAxisTickLineWidth / 2) +
                            xAxisTickLineWidth * index +
                            widget.coordinateSystemOrigin.dx,
                        _displayValue2YAxisOffsetValue(
                          value,
                          chartActualHeight: chartActualHeight,
                          yAxisDisplayValue2OffsetValueFactor:
                              yAxisDisplayValue2OffsetValueFactor,
                        ),
                      ),
                      radius: options.radius,
                      zoomedFactor: options.zoomedFactor,
                    ),
                  )
                  .toList(),
            )
        };

        _forwardAnimationControllerWhenIsDismissed();

        late double minOffsetValueOnYAxisSlidingArea;
        late double maxOffsetValueOnYAxisSlidingArea;

        if (widget.reversed) {
          minOffsetValueOnYAxisSlidingArea = 0.0;
          maxOffsetValueOnYAxisSlidingArea =
              (1 - _percentDerivedArea) * chartActualHeight;
        } else {
          minOffsetValueOnYAxisSlidingArea =
              _percentDerivedArea * chartActualHeight;
          maxOffsetValueOnYAxisSlidingArea = chartActualHeight;
        }

        final Widget coordinateSystemPainter = CustomPaint(
          size: Size(chartWidth, chartHeight),
          isComplex: true,
          painter: CoordinateSystemPainter<Enum>(
            slidableCoordinatesAnimationController:
                _slidableCoordinatesAnimationController,
            otherCoordinatesAnimationController:
                _otherCoordinatesAnimationController,
            slidableCoordinateType: widget.slidableCoordinateType,
            coordinatesMap: _coordinatesMap,
            xAxis: widget.xAxis,
            yAxis: _yAxis,
            divisions: widget.divisions,
            max: widget.max,
            min: widget.min,
            reversed: widget.reversed,
            onlyRenderEvenAxisLabel: widget.onlyRenderEvenAxisLabel,
            coordinateSystemOrigin: widget.coordinateSystemOrigin,
            maxOffsetValueOnYAxisSlidingArea: maxOffsetValueOnYAxisSlidingArea,
            slidableLineChartThemeData:
                SlidableLineChartTheme.maybeOf<Enum>(context),
            onDrawCheckOrClose: widget.onDrawCheckOrClose,
            getXAxisTickLineWidth: _getXAxisTickLineWidth,
            getYAxisTickLineHeight: _getYAxisTickLineHeight,
          ),
        );

        if (widget.onChange == null) {
          return Opacity(opacity: 0.6, child: coordinateSystemPainter);
        }

        if (_slidableCoordinates == null) {
          return coordinateSystemPainter;
        }

        return GestureDetector(
          onVerticalDragDown: (DragDownDetails details) {
            _currentSlideCoordinateIndex =
                _hitTestCoordinate(details.localPosition);

            if (_currentSlideCoordinateIndex != null) {
              HapticFeedback.mediumImpact();
            }
          },
          onVerticalDragStart: (DragStartDetails details) {
            _currentSlideCoordinateIndex ??=
                _hitTestCoordinate(details.localPosition);

            widget.onChangeStart?.call(_coordinatesMap.values
                .map((Coordinates<Enum> coordinates) => coordinates.toOptions())
                .toList());
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (_currentSlideCoordinateIndex != null) {
              final double displayValue = _getYAxisDisplayValueBySlidePrecision(
                details.localPosition.dy,
                chartActualHeight: chartActualHeight,
                minOffsetValueForSlidingAreaOnYAxis:
                    minOffsetValueOnYAxisSlidingArea,
                maxOffsetValueForSlidingAreaOnYAxis:
                    maxOffsetValueOnYAxisSlidingArea,
              );

              _coordinatesMap[widget.slidableCoordinateType]!
                      .value[_currentSlideCoordinateIndex!] =
                  _slidableCoordinates!.value[_currentSlideCoordinateIndex!]
                      .copyWith(value: displayValue);

              widget.onChange!.call(_coordinatesMap.values
                  .map(
                    (Coordinates<Enum> coordinates) => coordinates.toOptions(),
                  )
                  .toList());
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {
            _currentSlideCoordinateIndex = null;

            widget.onChangeEnd?.call(_coordinatesMap.values
                .map((Coordinates<Enum> coordinates) => coordinates.toOptions())
                .toList());
          },
          onVerticalDragCancel: () {
            _currentSlideCoordinateIndex = null;
          },
          child: RepaintBoundary(child: coordinateSystemPainter),
        );
      },
    );
  }
}
