part of 'coordinates_options.dart';

/// An instance of coordinate point mapped by [CoordinatesOptions].
@immutable
class Coordinate {
  /// Creates a coordinate point.
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

  /// Tests whether a given point will be considered to hit a coordinate point.
  ///
  /// Returns true if the user's touch point is within the range of
  /// [zoomedRect], otherwise returns false.
  bool hitTest(Offset position) => zoomedRect.contains(position);

  /// Creates a new [Coordinate] from this one by updating individual
  /// properties.
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
