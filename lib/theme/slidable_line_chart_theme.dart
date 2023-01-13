import 'package:flutter/material.dart';

part '../model/coordinates_style.dart';

const List<Color> kColorPalette = <Color>[
  Colors.blue,
  Colors.red,
  Colors.yellow,
  Colors.lightGreen,
];

const TextStyle kAxisLabelStyle = TextStyle(
  fontSize: 12,
  color: Colors.black,
);
const Color kAxisLineColor = Colors.black;
const double kAxisLineWidth = 1.0;
const Color kGridLineColor = Colors.blueGrey;
const double kGridLineWidth = 0.5;
const bool kShowTapArea = true;
const double kLineWidth = 2.0;
const TextStyle kDisplayValueTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.blueGrey,
);
const double kDisplayValueMarginBottom = 10.0;
const double kIndicatorMarginTop = 30.0;
const double kIndicatorRadius = 5.0;
const Color kCheckBackgroundColor = Colors.blue;
const Color kCloseBackgroundColor = Colors.red;
const Color kCheckColor = Colors.white;
const Color kCloseColor = Colors.white;
const double kSmooth = 0.0;

@immutable
class SlidableLineChartThemeData<E extends Enum> {
  const SlidableLineChartThemeData({
    this.coordinatesStyleList,
    this.axisLabelStyle,
    this.axisLineColor,
    this.axisLineWidth,
    this.gridLineColor,
    this.gridLineWidth,
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
  }) : assert(smooth == null || (smooth >= 0.0 && smooth <= 1.0),
            'smooth($smooth) must be between [0-1]');

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

  Map<E, CoordinatesStyle<E>>? get coordinatesStyleMap {
    if (coordinatesStyleList == null || coordinatesStyleList!.isEmpty) {
      return null;
    }

    return <E, CoordinatesStyle<E>>{
      for (final CoordinatesStyle<E> item in coordinatesStyleList!)
        item.type: item
    };
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

class SlidableLineChartTheme<E extends Enum> extends InheritedWidget {
  const SlidableLineChartTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final SlidableLineChartThemeData<E> data;

  static SlidableLineChartThemeData<E> of<E extends Enum>(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<E>>()!
        .data;
  }

  static SlidableLineChartThemeData<E>? maybeOf<E extends Enum>(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<E>>()
        ?.data;
  }

  @override
  bool updateShouldNotify(covariant SlidableLineChartTheme<E> oldWidget) =>
      data != oldWidget.data;
}
