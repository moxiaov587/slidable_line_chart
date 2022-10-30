part of 'coordinates_options.dart';

@immutable
class Coordinates<Enum> {
  const Coordinates({
    required this.type,
    required this.value,
  });

  factory Coordinates.formOptions(CoordinatesOptions<Enum> options) =>
      Coordinates<Enum>(
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

  CoordinatesOptions<Enum> toOptions() => CoordinatesOptions<Enum>(
        type,
        values: value.map((Coordinate coordinate) => coordinate.value).toList(),
      );

  final Enum type;
  final List<Coordinate> value;

  Coordinates<Enum> copyWith({List<Coordinate>? value}) => Coordinates<Enum>(
        type: type,
        value: value ?? this.value,
      );

  @override
  bool operator ==(Object other) {
    if (other is Coordinates<Enum>) {
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
