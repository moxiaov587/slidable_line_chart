part of 'coordinates_options.dart';

@immutable
class Coordinate {
  const Coordinate({
    required this.initialValue,
    this.value,
    this.offset = Offset.zero,
    required this.width,
    required this.height,
    required this.zoomedFactor,
  });

  final double initialValue;
  final double? value;
  final Offset offset;
  final double width;
  final double height;

  final double zoomedFactor;

  double get currentValue => value ?? initialValue;

  Rect get rect => Rect.fromCenter(
        center: offset,
        width: width,
        height: height,
      );

  /// 放大的[Rect]
  ///
  /// 用于增大触摸生效的判定区域
  Rect get zoomedRect => Rect.fromCenter(
        center: offset,
        width: min(kMinInteractiveDimension, width * zoomedFactor),
        height: min(kMinInteractiveDimension, height * zoomedFactor),
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
    double? width,
    double? height,
    double? zoomedFactor,
    bool enforceOverrideValue = false,
  }) =>
      Coordinate(
        initialValue: initialValue,
        offset: offset ?? this.offset,
        value: enforceOverrideValue ? value : value ?? this.value,
        width: width ?? this.width,
        height: height ?? this.height,
        zoomedFactor: zoomedFactor ?? this.zoomedFactor,
      );

  @override
  int get hashCode => Object.hash(
        initialValue,
        offset,
        value,
        width,
        height,
        zoomedFactor,
      );

  @override
  bool operator ==(Object other) =>
      other is Coordinate &&
      other.initialValue == initialValue &&
      other.offset == offset &&
      other.value == value &&
      other.width == width &&
      other.height == height &&
      other.zoomedFactor == zoomedFactor;
}
