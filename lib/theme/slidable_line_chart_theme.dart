import 'package:flutter/material.dart';

import '../coordinate_system_painter.dart' show CoordinateSystemPainter;
import '../model/coordinates_options.dart' show Coordinates;
import '../slidable_line_chart.dart' show SlidableLineChart;

part '../model/coordinates_style.dart';

/// Coordinate point color by default.
const List<Color> kColorPalette = <Color>[
  Colors.blue,
  Colors.red,
  Colors.yellow,
  Colors.lightGreen,
];

/// Axis label style by default.
const TextStyle kAxisLabelStyle = TextStyle(
  fontSize: 12,
  color: Colors.black,
);

/// Axis line color by default.
const Color kAxisLineColor = Colors.black;

/// Axis line width by default.
const double kAxisLineWidth = 1.0;

/// Grid line color by default.
const Color kGridLineColor = Colors.blueGrey;

/// Grid line width by default.
const double kGridLineWidth = 0.5;

/// Show tap area by default.
const bool kShowTapArea = true;

/// Line width by default.
const double kLineWidth = 2.0;

/// Display value text style by default.
const TextStyle kDisplayValueTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.blueGrey,
);

/// Display value text margin bottom by default.
const double kDisplayValueMarginBottom = 10.0;

/// Indicator margin top by default.
const double kIndicatorMarginTop = 30.0;

/// Indicator radius by default.
const double kIndicatorRadius = 5.0;

/// Check background color by default.
const Color kCheckBackgroundColor = Colors.blue;

/// Close background color by default.
const Color kCloseBackgroundColor = Colors.red;

/// Check symbol color by default.
const Color kCheckColor = Colors.white;

/// Close symbol color by default.
const Color kCloseColor = Colors.white;

/// Smoothness by default.
const double kSmooth = 0.0;

/// Opacity by default.
const double kDisabledOpacity = 0.6;

/// The default type of grid lines to draw.
const DrawGridLineType kDrawGridLineType = DrawGridLineType.onlyXAxis;

/// The default style of grid lines to draw.
const DrawGridLineStyle kDrawGridLineStyle = DrawGridLineStyle.normal;

/// The default unit width of the dashed grid lines.
const double kDashedGridLineWidth = 4.0;

/// The default gap width of the dashed grid lines.
const double kDashedGridLineGap = 2.0;

/// {@template package.DrawGridLineType}
/// The type of grid lines to draw.
/// {@endtemplate}
enum DrawGridLineType {
  /// Both the x-axis and y-axis grid lines should be drawn.
  all,

  /// Draw grid lines only on the x-axis.
  onlyXAxis,

  /// Draw grid lines only on the y-axis.
  onlyYAxis,

  /// Do not draw grid lines on the x-axis or y-axis.
  none,
}

/// {@template package.DrawGridLineStyle}
/// The style of grid lines to draw.
/// {@endtemplate}
enum DrawGridLineStyle {
  /// Draw to straight line.
  normal,

  /// Draw to dashed line.
  dashed,
}

/// {@template package.SlidableLineChartThemeData}
/// Defines the configuration of the overall visual [SlidableLineChartThemeData]
/// for a [SlidableLineChart].
/// {@endtemplate}
@immutable
class SlidableLineChartThemeData<E extends Enum> {
  /// Create a [SlidableLineChartThemeData] that's used to configure a
  /// [SlidableLineChartTheme].
  const SlidableLineChartThemeData({
    this.coordinatesStyleList,
    this.axisLabelStyle,
    this.axisLineColor,
    this.axisLineWidth,
    this.gridLineColor,
    this.gridLineWidth,
    this.drawGridLineType,
    this.drawGridLineStyle,
    this.dashedGridLineWidth,
    this.dashedGridLineGap,
    this.showTapArea,
    this.lineWidth,
    this.displayValueTextStyle,
    this.displayValueMarginBottom,
    this.indicatorMarginTop,
    this.indicatorRadius,
    this.checkBackgroundColor,
    this.closeBackgroundColor,
    this.checkColor,
    this.closeColor,
    this.smooth,
    this.disabledOpacity,
  })  : assert(
          smooth == null || (smooth >= 0.0 && smooth <= 1.0),
          'smooth($smooth) must be between [0-1]',
        ),
        assert(
          disabledOpacity == null ||
              (disabledOpacity >= 0.0 && disabledOpacity <= 1.0),
          'disabledOpacity($disabledOpacity) must be between [0-1]',
        );

  /// All coordinates style list.
  ///
  /// Can specify a style for each type of coordinates individually.
  ///
  /// The latter overrides the former when style of the same type exists.
  final List<CoordinatesStyle<E>>? coordinatesStyleList;

  /// Axis label style for the coordinate system.
  ///
  /// If this value are null, then [kAxisLabelStyle] will be used.
  final TextStyle? axisLabelStyle;

  /// Axis line color for the coordinate system.
  ///
  /// If this value are null, then [kAxisLineColor] will be used.
  final Color? axisLineColor;

  /// Axis line width for the coordinate system.
  ///
  /// If this value are null, then [kAxisLineWidth] will be used.
  final double? axisLineWidth;

  /// Grid line color for the coordinate system.
  ///
  /// If this value are null, then [kGridLineColor] will be used.
  final Color? gridLineColor;

  /// Grid line width for the coordinate system.
  ///
  /// If this value are null, then [kGridLineWidth] will be used.
  final double? gridLineWidth;

  /// {@macro package.DrawGridLineType}
  ///
  /// If this value are null, then [kDrawGridLineType] will be used.
  final DrawGridLineType? drawGridLineType;

  /// {@macro package.DrawGridLineStyle}
  ///
  /// If this value are null, then [kDrawGridLineStyle] will be used.
  final DrawGridLineStyle? drawGridLineStyle;

  /// The unit width of the dashed grid lines.
  ///
  /// Only works when [drawGridLineStyle] is equal to
  /// [DrawGridLineStyle.dashed].
  ///
  /// If this value are null, then [kDashedGridLineWidth] will be used.
  final double? dashedGridLineWidth;

  /// The gap width of the dashed grid lines.
  ///
  /// Only works when [drawGridLineStyle] is equal to
  /// [DrawGridLineStyle.dashed].
  ///
  /// If this value are null, then [kDashedGridLineGap] will be used.
  final double? dashedGridLineGap;

  /// Whether to display the user's touch area.
  ///
  /// If this value are null, then [kShowTapArea] will be used.
  final bool? showTapArea;

  /// Line width on the all coordinates.
  ///
  /// If this value are null, then [kLineWidth] will be used.
  final double? lineWidth;

  /// Text style for display value on the coordinate system.
  ///
  /// If this value are null, then [kDisplayValueTextStyle] will be used.
  final TextStyle? displayValueTextStyle;

  /// Margin bottom for display value on the coordinate system.
  ///
  /// If this value are null, then [kDisplayValueMarginBottom] will be used.
  final double? displayValueMarginBottom;

  /// Margin top for check or close indicator on the coordinate system.
  ///
  /// If this value are null, then [kIndicatorMarginTop] will be used.
  final double? indicatorMarginTop;

  /// Radius for check or close indicator on the coordinate system.
  ///
  /// If this value are null, then [kIndicatorRadius] will be used.
  final double? indicatorRadius;

  /// Background color for check indicator on the coordinate system.
  ///
  /// If this value are null, then [kCheckBackgroundColor] will be used.
  final Color? checkBackgroundColor;

  /// Background color for close indicator on the coordinate system.
  ///
  /// If this value are null, then [kCloseBackgroundColor] will be used.
  final Color? closeBackgroundColor;

  /// Color for check symbol on the coordinate system.
  ///
  /// If this value are null, then [kCheckColor] will be used.
  final Color? checkColor;

  /// Color for close symbol on the coordinate system.
  ///
  /// If this value are null, then [kCloseColor] will be used.
  final Color? closeColor;

  /// Smoothness of the line chart.
  ///
  /// Value range is [0-1], smaller means closer to the polyline.
  ///
  /// Typically, 0.5 is used to display as curve.
  ///
  /// If this value are null, then [kSmooth] will be used.
  final double? smooth;

  /// Opacity when line chart is can't change.
  ///
  /// Value range is [0-1], smaller means closer to the polyline.
  ///
  /// If this value are null, then [kDisabledOpacity] will be used.
  final double? disabledOpacity;

  /// Generate a [Map] from the current [coordinatesStyleList].
  ///
  /// Convenient and efficient access to the corresponding [E] of
  /// [CoordinatesStyle].
  Map<E, CoordinatesStyle<E>>? get coordinatesStyleMap {
    if (coordinatesStyleList == null || coordinatesStyleList!.isEmpty) {
      return null;
    }

    return <E, CoordinatesStyle<E>>{
      for (final CoordinatesStyle<E> item in coordinatesStyleList!)
        item.type: item,
    };
  }

  /// Creates a copy of this theme data but with the given fields replaced with
  /// the new values.
  SlidableLineChartThemeData<E> copyWith({
    List<CoordinatesStyle<E>>? coordinatesStyleList,
    TextStyle? axisLabelStyle,
    Color? axisLineColor,
    double? axisLineWidth,
    Color? gridLineColor,
    double? gridLineWidth,
    DrawGridLineType? drawGridLineType,
    DrawGridLineStyle? drawGridLineStyle,
    double? dashedGridLineWidth,
    double? dashedGridLineGap,
    bool? showTapArea,
    double? lineWidth,
    TextStyle? displayValueTextStyle,
    double? displayValueMarginBottom,
    double? indicatorMarginTop,
    double? indicatorRadius,
    Color? checkBackgroundColor,
    Color? closeBackgroundColor,
    Color? checkColor,
    Color? closeColor,
    double? smooth,
    double? disabledOpacity,
  }) {
    assert(
      smooth == null || (smooth >= 0.0 && smooth <= 1.0),
      'smooth($smooth) must be between [0-1]',
    );
    assert(
      disabledOpacity == null ||
          (disabledOpacity >= 0.0 && disabledOpacity <= 1.0),
      'disabledOpacity($disabledOpacity) must be between [0-1]',
    );

    return SlidableLineChartThemeData<E>(
      coordinatesStyleList: coordinatesStyleList ?? this.coordinatesStyleList,
      drawGridLineType: drawGridLineType ?? this.drawGridLineType,
      drawGridLineStyle: drawGridLineStyle ?? this.drawGridLineStyle,
      dashedGridLineWidth: dashedGridLineWidth ?? this.dashedGridLineWidth,
      dashedGridLineGap: dashedGridLineGap ?? this.dashedGridLineGap,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
      axisLineColor: axisLineColor ?? this.axisLineColor,
      axisLineWidth: axisLineWidth ?? this.axisLineWidth,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      showTapArea: showTapArea ?? this.showTapArea,
      lineWidth: lineWidth ?? this.lineWidth,
      displayValueTextStyle:
          displayValueTextStyle ?? this.displayValueTextStyle,
      displayValueMarginBottom:
          displayValueMarginBottom ?? this.displayValueMarginBottom,
      indicatorMarginTop: indicatorMarginTop ?? this.indicatorMarginTop,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
      checkBackgroundColor: checkBackgroundColor ?? this.checkBackgroundColor,
      closeBackgroundColor: closeBackgroundColor ?? this.closeBackgroundColor,
      checkColor: checkColor ?? this.checkColor,
      closeColor: closeColor ?? this.closeColor,
      smooth: smooth ?? this.smooth,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SlidableLineChartThemeData<E>) {
      if (coordinatesStyleList?.length != other.coordinatesStyleList?.length) {
        return false;
      }

      if (coordinatesStyleList == null || other.coordinatesStyleList == null) {
        return axisLabelStyle == other.axisLabelStyle &&
            axisLineColor == other.axisLineColor &&
            gridLineColor == other.gridLineColor &&
            showTapArea == other.showTapArea &&
            lineWidth == other.lineWidth &&
            other.displayValueTextStyle == displayValueTextStyle &&
            other.displayValueMarginBottom == displayValueMarginBottom &&
            other.indicatorMarginTop == indicatorMarginTop &&
            other.indicatorRadius == indicatorRadius &&
            other.checkBackgroundColor == checkBackgroundColor &&
            other.closeBackgroundColor == closeBackgroundColor &&
            other.checkColor == checkColor &&
            other.closeColor == closeColor &&
            other.smooth == smooth;
      }

      for (int i = 0; i < coordinatesStyleList!.length; i++) {
        if (coordinatesStyleList![i] != other.coordinatesStyleList![i]) {
          return false;
        }
      }

      return axisLabelStyle == other.axisLabelStyle &&
          axisLineColor == other.axisLineColor &&
          gridLineColor == other.gridLineColor &&
          showTapArea == other.showTapArea &&
          lineWidth == other.lineWidth &&
          other.displayValueTextStyle == displayValueTextStyle &&
          other.displayValueMarginBottom == displayValueMarginBottom &&
          other.indicatorMarginTop == indicatorMarginTop &&
          other.indicatorRadius == indicatorRadius &&
          other.checkBackgroundColor == checkBackgroundColor &&
          other.closeBackgroundColor == closeBackgroundColor &&
          other.checkColor == checkColor &&
          other.closeColor == closeColor &&
          other.smooth == smooth;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(
        coordinatesStyleList != null
            ? Object.hashAll(coordinatesStyleList!)
            : null,
        axisLabelStyle,
        axisLineColor,
        gridLineColor,
        showTapArea,
        lineWidth,
        displayValueTextStyle,
        displayValueMarginBottom,
        indicatorMarginTop,
        indicatorRadius,
        checkBackgroundColor,
        closeBackgroundColor,
        checkColor,
        closeColor,
        smooth,
      );
}

/// An [InheritedWidget] that defines visual properties like colors and text
/// styles, which the [CoordinateSystemPainter] in the subtree depends on.
class SlidableLineChartTheme<E extends Enum> extends InheritedWidget {
  /// Create a [SlidableLineChartTheme] to provide [SlidableLineChartThemeData]
  /// to [CoordinateSystemPainter] in the subtree.
  const SlidableLineChartTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The [SlidableLineChartThemeData] provided to the
  /// [CoordinateSystemPainter] in the subtree.
  final SlidableLineChartThemeData<E> data;

  /// The data from the closest [SlidableLineChartTheme] instance that encloses
  /// the given context.
  static SlidableLineChartThemeData<E> of<E extends Enum>(
    BuildContext context,
  ) =>
      context
          .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<E>>()!
          .data;

  /// The data from the closest [SlidableLineChartTheme] instance that encloses
  /// the given context, if any.
  static SlidableLineChartThemeData<E>? maybeOf<E extends Enum>(
    BuildContext context,
  ) =>
      context
          .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<E>>()
          ?.data;

  @override
  bool updateShouldNotify(covariant SlidableLineChartTheme<E> oldWidget) =>
      data != oldWidget.data;
}
