part of 'coordinates_options.dart';

/// An instance of mapped by [CoordinatesOptions].
@immutable
class Coordinates<E extends Enum> {
  /// Create coordinates.
  const Coordinates({
    required this.type,
    required this.value,
  });

  /// Generate a [Coordinates] derived from the given [CoordinatesOptions].
  factory Coordinates.formOptions(CoordinatesOptions<E> options) =>
      Coordinates<E>(
        type: options.type,
        value: options.values
            .map(
              (double value) => Coordinate(
                value: value,
                radius: options.radius,
                zoomedFactor: options.zoomedFactor,
              ),
            )
            .toList(),
      );

  /// Generate a [CoordinatesOptions] from the current [Coordinates].
  CoordinatesOptions<E> toOptions() => CoordinatesOptions<E>(
        type,
        values: value.map((Coordinate coordinate) => coordinate.value).toList(),
      );

  /// Type of coordinates.
  final E type;

  /// All coordinate point.
  final List<Coordinate> value;

  /// Creates a new [Coordinates] from this one by updating individual
  /// properties.
  Coordinates<E> copyWith({List<Coordinate>? value}) => Coordinates<E>(
        type: type,
        value: value ?? this.value,
      );

  @override
  bool operator ==(Object other) {
    if (other is Coordinates<E>) {
      if (value.length != other.value.length) {
        return false;
      }

      for (int i = 0; i < value.length; i++) {
        if (value[i] != other.value[i]) {
          return false;
        }
      }

      return type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(value),
      );
}
