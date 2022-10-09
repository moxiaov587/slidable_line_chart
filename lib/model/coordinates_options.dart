import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/slidable_line_chart_theme.dart';

part 'coordinate.dart';
part 'coordinates.dart';

@immutable
class CoordinatesOptions<Enum> {
  const CoordinatesOptions(
    this.type, {
    required this.values,
    this.width = 12.0,
    this.height = 12.0,
    this.zoomedFactor = 3.0,
  });

  final Enum type;
  final List<double> values;

  final double width;
  final double height;

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
          width == other.width &&
          height == other.height &&
          zoomedFactor == other.zoomedFactor;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(values),
        width,
        height,
        zoomedFactor,
      );
}
