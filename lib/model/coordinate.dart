part of 'coordinates_options.dart';

@immutable
class Coordinate {
  const Coordinate({
    required this.value,
    this.offset = Offset.zero,
    required this.radius,
    required this.zoomedFactor,
  }) : _zoomedRadius = radius * zoomedFactor;

  /// Value that change as the user slides.
  ///
  /// It is also the value displayed on the coordinate system.
  final double value;

  /// The center of the coordinate point.
  final Offset offset;

  /// The radius of the coordinate point.
  final double radius;

  /// Increase the magnification factor of the touch area.
  final double zoomedFactor;

  /// Zoomed radius of coordinate points.
  final double _zoomedRadius;

  /// Rect of coordinate points.
  Rect get rect => Rect.fromCircle(
        center: offset,
        radius: radius,
      );

  /// Zoomed rect of coordinate points.
  Rect get zoomedRect => Rect.fromCircle(
        center: offset,
        radius: _zoomedRadius,
      );

  bool hitTest(Offset position) => zoomedRect.contains(position);

  void drawCoordinatePoint(Canvas canvas, Paint paint) {
    canvas.drawOval(rect, paint);
  }

  void drawTapArea(Canvas canvas, Paint paint) {
    canvas.drawOval(zoomedRect, paint);
  }

  Coordinate copyWith({
    double? value,
    Offset? offset,
    double? radius,
    double? zoomedFactor,
  }) =>
      Coordinate(
        value: value ?? this.value,
        offset: offset ?? this.offset,
        radius: radius ?? this.radius,
        zoomedFactor: zoomedFactor ?? this.zoomedFactor,
      );

  @override
  int get hashCode => Object.hash(
        value,
        offset,
        radius,
        zoomedFactor,
      );

  @override
  bool operator ==(Object other) =>
      other is Coordinate &&
      other.value == value &&
      other.offset == offset &&
      other.radius == radius &&
      other.zoomedFactor == zoomedFactor;
}
