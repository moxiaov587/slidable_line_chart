part of 'coordinates_options.dart';

@immutable
class Coordinates<E extends Enum> {
  const Coordinates({
    required this.type,
    required this.value,
  });

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

  CoordinatesOptions<E> toOptions() => CoordinatesOptions<E>(
        type,
        values: value.map((Coordinate coordinate) => coordinate.value).toList(),
      );

  final E type;
  final List<Coordinate> value;

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
