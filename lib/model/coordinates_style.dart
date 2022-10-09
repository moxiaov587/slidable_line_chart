part of '../theme/slidable_line_chart_theme.dart';

@immutable
class CoordinatesStyle<Enum> {
  const CoordinatesStyle({
    required this.type,
    this.pointColor,
    this.linkLineColor,
    this.fillAreaColor,
  });

  final Enum type;

  /// 坐标点颜色
  final Color? pointColor;

  /// 连接线颜色
  final Color? linkLineColor;

  /// 覆盖区域颜色
  final Color? fillAreaColor;

  @override
  bool operator ==(Object other) {
    return other is CoordinatesStyle<Enum> &&
        type == other.type &&
        pointColor == other.pointColor &&
        linkLineColor == other.linkLineColor &&
        fillAreaColor == other.fillAreaColor;
  }

  @override
  int get hashCode => Object.hash(
        type,
        pointColor,
        linkLineColor,
        fillAreaColor,
      );
}
