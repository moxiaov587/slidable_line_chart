part of 'coordinates_options.dart';

@immutable
class Coordinates<Enum> {
  const Coordinates({
    required this.type,
    required this.value,
    this.style,
  });

  factory Coordinates.formOptions(
    CoordinatesOptions<Enum> options, {
    CoordinatesStyle<Enum>? coordinateStyle,
  }) =>
      Coordinates<Enum>(
        type: options.type,
        value: options.values
            .map(
              (double value) => Coordinate(
                initialValue: value,
                radius: options.radius,
                zoomedFactor: options.zoomedFactor,
              ),
            )
            .toList(),
        style: coordinateStyle,
      );

  final Enum type;
  final List<Coordinate> value;
  final CoordinatesStyle<Enum>? style;

  Coordinates<Enum> copyWith({
    List<Coordinate>? value,
    CoordinatesStyle<Enum>? style,
    bool enforceOverrideStyle = false,
  }) =>
      Coordinates<Enum>(
        type: type,
        value: value ?? this.value,
        style: enforceOverrideStyle ? style : style ?? this.style,
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

      return type == other.type && style == other.style;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(value),
        style,
      );
}
