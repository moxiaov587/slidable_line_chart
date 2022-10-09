import 'package:flutter/material.dart';

part '../model/coordinates_style.dart';

const Color kAxisLineColor = Colors.black;
const TextStyle kAxisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black,
);
const Color kGridLineColor = Colors.blueGrey;
const Color kTapAreaColor = Colors.red;
const Color kDefaultCoordinatePointColor = Colors.blue;
const Color kDefaultLinkLineColor = Colors.blueAccent;
const Color kDefaultFillAreaColor = Colors.blue;
const TextStyle kCurrentValueTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.blueGrey,
);
const double kCurrentValueMarginBottom = 10.0;
const double kCheckOrCloseIconMarginTop = 30.0;
const double kCheckOrCloseIconSize = 10.0;
const double kCloseSize = 4.0;
const Color kCheckBackground = Colors.blue;
const Color kCloseBackground = Colors.red;
const Color kCheckColor = Colors.white;
const Color kCloseColor = Colors.white;

@immutable
class SlidableLineChartThemeData<Enum> {
  const SlidableLineChartThemeData({
    this.coordinatesStyleList,
    this.axisTextStyle,
    this.axisLineColor,
    this.gridLineColor,
    this.tapAreaColor,
    this.defaultCoordinatePointColor,
    this.defaultLinkLineColor,
    this.defaultFillAreaColor,
    this.currentValueTextStyle,
    this.currentValueMarginBottom = kCurrentValueMarginBottom,
    this.checkOrCloseIconMarginTop = kCheckOrCloseIconMarginTop,
    this.checkOrCloseIconSize = kCheckOrCloseIconSize,
    this.closeSize = kCloseSize,
    this.checkBackground,
    this.closeBackground,
    this.checkColor,
    this.closeColor,
  });

  final List<CoordinatesStyle<Enum>>? coordinatesStyleList;

  /// 坐标轴文本样式
  final TextStyle? axisTextStyle;

  /// 坐标轴颜色
  final Color? axisLineColor;

  /// 坐标系网格颜色
  final Color? gridLineColor;

  /// 触摸区域颜色
  final Color? tapAreaColor;

  /// 坐标点颜色
  final Color? defaultCoordinatePointColor;

  /// 连接线颜色
  final Color? defaultLinkLineColor;

  /// 覆盖区域颜色
  final Color? defaultFillAreaColor;

  /// 当前值文本样式
  final TextStyle? currentValueTextStyle;

  final double currentValueMarginBottom;

  final double checkOrCloseIconMarginTop;
  final double checkOrCloseIconSize;
  final double closeSize;
  final Color? checkBackground;
  final Color? closeBackground;
  final Color? checkColor;
  final Color? closeColor;

  Map<Enum, CoordinatesStyle<Enum>> get coordinatesStyleMap =>
      <Enum, CoordinatesStyle<Enum>>{
        for (final CoordinatesStyle<Enum> item
            in coordinatesStyleList ?? <CoordinatesStyle<Enum>>[])
          item.type: item
      };

  @override
  bool operator ==(Object other) {
    if (other is SlidableLineChartThemeData<Enum>) {
      if (coordinatesStyleList?.length != other.coordinatesStyleList?.length) {
        return false;
      }

      if (coordinatesStyleList == null || other.coordinatesStyleList == null) {
        return axisTextStyle == other.axisTextStyle &&
            axisLineColor == other.axisLineColor &&
            gridLineColor == other.gridLineColor &&
            tapAreaColor == other.tapAreaColor &&
            defaultCoordinatePointColor == other.defaultCoordinatePointColor &&
            defaultLinkLineColor == other.defaultLinkLineColor &&
            defaultFillAreaColor == other.defaultFillAreaColor &&
            other.currentValueTextStyle == currentValueTextStyle &&
            other.currentValueMarginBottom == currentValueMarginBottom &&
            other.checkOrCloseIconMarginTop == checkOrCloseIconMarginTop &&
            other.checkOrCloseIconSize == checkOrCloseIconSize &&
            other.closeSize == closeSize &&
            other.checkBackground == checkBackground &&
            other.closeBackground == closeBackground &&
            other.checkColor == checkColor &&
            other.closeColor == closeColor;
      }

      for (int i = 0; i < coordinatesStyleList!.length; i++) {
        if (coordinatesStyleList![i] != other.coordinatesStyleList![i]) {
          return false;
        }
      }

      return axisTextStyle == other.axisTextStyle &&
          axisLineColor == other.axisLineColor &&
          gridLineColor == other.gridLineColor &&
          tapAreaColor == other.tapAreaColor &&
          defaultCoordinatePointColor == other.defaultCoordinatePointColor &&
          defaultLinkLineColor == other.defaultLinkLineColor &&
          defaultFillAreaColor == other.defaultFillAreaColor &&
          other.currentValueTextStyle == currentValueTextStyle &&
          other.currentValueMarginBottom == currentValueMarginBottom &&
          other.checkOrCloseIconMarginTop == checkOrCloseIconMarginTop &&
          other.checkOrCloseIconSize == checkOrCloseIconSize &&
          other.closeSize == closeSize &&
          other.checkBackground == checkBackground &&
          other.closeBackground == closeBackground &&
          other.checkColor == checkColor &&
          other.closeColor == closeColor;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(
        coordinatesStyleList != null
            ? Object.hashAll(coordinatesStyleList!)
            : null,
        axisTextStyle,
        axisLineColor,
        gridLineColor,
        tapAreaColor,
        defaultCoordinatePointColor,
        defaultLinkLineColor,
        defaultFillAreaColor,
        currentValueTextStyle,
        currentValueMarginBottom,
        checkOrCloseIconMarginTop,
        checkOrCloseIconSize,
        closeSize,
        checkBackground,
        closeBackground,
        checkColor,
        closeColor,
      );
}

class SlidableLineChartTheme<Enum> extends InheritedWidget {
  const SlidableLineChartTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final SlidableLineChartThemeData<Enum> data;

  static SlidableLineChartThemeData<Enum> of<Enum>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<Enum>>()!
        .data;
  }

  static SlidableLineChartThemeData<Enum>? maybeOf<Enum>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SlidableLineChartTheme<Enum>>()
        ?.data;
  }

  @override
  bool updateShouldNotify(covariant SlidableLineChartTheme<Enum> oldWidget) =>
      data != oldWidget.data;
}
