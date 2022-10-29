import 'package:flutter/material.dart';

part 'coordinate.dart';
part 'coordinates.dart';

@immutable
class CoordinatesOptions<Enum> {
  const CoordinatesOptions(
    this.type, {
    required this.values,
    this.radius = 6.0,
    this.zoomedFactor = 3.0,
  });

  /// Type of coordinates options.
  final Enum type;

  /// The value displayed in the coordinate system for each coordinate point.
  final List<double> values;

  /// Radius of coordinate points.
  ///
  /// Defaults to 6.0.
  final double radius;

  /// Magnification factor of the touch area.
  ///
  /// Defaults to 3.0.
  final double zoomedFactor;

  @override
  bool operator ==(Object other) {
    if (other is CoordinatesOptions<Enum>) {
      if (values.length != other.values.length) {
        return false;
      }

      for (int i = 0; i < values.length; i++) {
        if (values[i] != other.values[i]) {
          return false;
        }
      }

      return type == other.type &&
          radius == other.radius &&
          zoomedFactor == other.zoomedFactor;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(values),
        radius,
        zoomedFactor,
      );
}
