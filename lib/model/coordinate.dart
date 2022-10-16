part of 'coordinates_options.dart';

@immutable
class Coordinate {
  const Coordinate({
    required this.initialValue,
    this.value,
    this.offset = Offset.zero,
    required this.radius,
    required this.zoomedFactor,
  }) : _zoomedRadius = radius * zoomedFactor;

  /// The initial value of the coordinate point.
  ///
  /// Used to reset display value.
  final double initialValue;

  /// Drag with the user to change the value.
  final double? value;

  /// The center of the coordinate point.
  final Offset offset;

  /// The radius of the coordinate point.
  final double radius;

  /// Increase the magnification factor of the touch area.
  final double zoomedFactor;

  /// Zoomed radius of coordinate points.
  final double _zoomedRadius;

  /// The value displayed in the coordinate system.
  double get displayValue => value ?? initialValue;

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
    Offset? offset,
    double? value,
    double? radius,
    double? zoomedFactor,
    bool enforceOverrideValue = false,
  }) =>
      Coordinate(
        initialValue: initialValue,
        offset: offset ?? this.offset,
        value: enforceOverrideValue ? value : value ?? this.value,
        radius: radius ?? this.radius,
        zoomedFactor: zoomedFactor ?? this.zoomedFactor,
      );

  @override
  int get hashCode => Object.hash(
        initialValue,
        offset,
        value,
        radius,
        zoomedFactor,
      );

  @override
  bool operator ==(Object other) =>
      other is Coordinate &&
      other.initialValue == initialValue &&
      other.offset == offset &&
      other.value == value &&
      other.radius == radius &&
      other.zoomedFactor == zoomedFactor;
}
