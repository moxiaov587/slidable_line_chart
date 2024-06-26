import 'package:flutter/material.dart';

import '../slidable_line_chart.dart' show SlidableLineChart;

part 'coordinate.dart';
part 'coordinates.dart';

/// Coordinates options radius by default.
const double kDefaultCoordinatesOptionsRadius = 6.0;

/// Coordinates options zoomed factor by default.
const double kDefaultCoordinatesOptionsZoomedFactor = 3.0;

/// Define a configuration for a set of coordinate points.
@immutable
class CoordinatesOptions<E extends Enum> {
  /// Create [CoordinatesOptions] to add a polyline to [SlidableLineChart].
  const CoordinatesOptions(
    this.type, {
    required this.values,
    this.radius = kDefaultCoordinatesOptionsRadius,
    this.zoomedFactor = kDefaultCoordinatesOptionsZoomedFactor,
  });

  /// Type of coordinates options.
  final E type;

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
    if (other is CoordinatesOptions<E>) {
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
