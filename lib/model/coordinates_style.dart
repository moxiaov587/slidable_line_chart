part of '../theme/slidable_line_chart_theme.dart';

@immutable
class CoordinatesStyle<Enum> {
  const CoordinatesStyle({
    required this.type,
    this.pointColor,
    this.tapAreaColor,
    this.lineColor,
    this.fillAreaColor,
  });

  /// Type of coordinates style.
  final Enum type;

  /// Color of coordinate point.
  final Color? pointColor;

  /// Color of the response area when the coordinate point is draggable.
  final Color? tapAreaColor;

  /// Color of coordinate line.
  final Color? lineColor;

  /// Color of fill area.
  final Color? fillAreaColor;

  @override
  bool operator ==(Object other) {
    return other is CoordinatesStyle<Enum> &&
        type == other.type &&
        pointColor == other.pointColor &&
        tapAreaColor == other.tapAreaColor &&
        lineColor == other.lineColor &&
        fillAreaColor == other.fillAreaColor;
  }

  @override
  int get hashCode => Object.hash(
        type,
        pointColor,
        tapAreaColor,
        lineColor,
        fillAreaColor,
      );
}
