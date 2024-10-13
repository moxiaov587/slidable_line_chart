A line chart plugin that responds to user sliding. Supports reverse and custom slide precision.

## Features

Show a line chart and change it.

- Implementation base on Flutter
- Supports multiple lines but currently only supports dragging one of them
- Supports reversed y-axis
- Supports set the minimum value for each slide by the user
- Supports dark mode and custom styles

## Live preview

[Link](https://moxiaov587.github.io/slidable_line_chart/)

## Preview

| ![](screenshots/preview.gif) |
| ---------------------------- |

## Usage
```dart
import 'package:slidable_line_chart/slidable_line_chart.dart';
```

Fields in `CoordinatesOptions`:

| Name         | Type           | Description                                                             | Default Value |
|--------------|----------------|-------------------------------------------------------------------------|---------------|
| type         | `Enum?`        | Type of coordinates options                                             | `null`        |
| values       | `List<double>` | The value displayed in the coordinate system for each coordinate point. | `none`        |
| radius       | `double`       | Radius of coordinate points.                                            | `none`        |
| zoomedFactor | `double`       | Magnification factor of the touch area.                                 | `none`        |


Fields in `SlidableLineChart`:

| Name                            | Type                              | Description                                                                             | Default Value                |
|---------------------------------|-----------------------------------|-----------------------------------------------------------------------------------------|------------------------------|
| slidableCoordinateType          | `Enum?`                           | The type of coordinates the user can slide.                                             | `null`                       |
| coordinatesOptionsList          | `List<CoordinatesOptions<Enum>>`  | An array contain coordinates configuration information.                                 | `none`                       |
| xAxis                           | `List<String>`                    | Labels displayed on the x-axis.                                                         | `none`                       |
| min                             | `int`                             | The minimum value that the user can slide to.                                           | `none`                       |
| max                             | `int`                             | The maximum value that the user can slide to.                                           | `none`                       |
| coordinateSystemOrigin          | `Offset`                          | Coordinate system origin offset value.                                                  | `const Offset(6.0, 6.0)`     |
| divisions                       | `int`                             | The division value of y-axis.                                                           | `1`                          |
| slidePrecision                  | `double?`                         | The minimum value for each slide by the user.                                           | `null`                       |
| reversed                        | `bool`                            | Whether the coordinate system is reversed.                                              | `false`                      |
| onlyRenderEvenAxisLabel         | `bool`                            | Whether the y-axis label renders only even items.                                       | `true`                       |
| enableInitializationAnimation   | `bool`                            | Whether the coordinate system triggers animation when initialized.                      | `true`                       |
| initializationAnimationDuration | `Duration`                        | Initialize the duration of the animation.                                               | `const Duration(seconds: 1)` |
| fillWidth                       | `bool`                            | Align the first and last points of the chart with both ends.                            | `false`                      |
| enableFeedback                  | `bool`                            | Whether audible and/or haptic feedback should be provided during user interaction.      | `true`                       |
| onDrawCheckOrClose              | `OnDrawCheckOrClose?`             | Called when the user slides coordinate, the return value determines the indicator type. | `null`                       |
| onChange                        | `CoordinatesOptionsChanged<Enum>` | Called when the user slides coordinate.                                                 | `null`                       |
| onChangeStart                   | `CoordinatesOptionsChanged<Enum>` | Called when the user starts sliding coordinate.                                         | `null`                       |
| onChangeEnd                     | `CoordinatesOptionsChanged<Enum>` | Called when the user stops sliding coordinate.                                          | `null`                       |

Fields in `CoordinatesStyle`:

| Name          | Type     | Description                                                    | Default Value |
|---------------|----------|----------------------------------------------------------------|---------------|
| type          | `Enum?`  | Type of coordinates style                                      | `null`        |
| pointColor    | `Color?` | Color of coordinate point.                                     | `none`        |
| tapAreaColor  | `Color?` | Color of the touch area when the coordinate point is slidable. | `none`        |
| lineColor     | `Color?` | Color of coordinate line.                                      | `none`        |
| fillAreaColor | `Color?` | Color of fill area.                                            | `none`        |

Fields in `SlidableLineChartThemeData`:

| Name                        | Type                             | Description                                                       | Default Value |
|-----------------------------|----------------------------------|-------------------------------------------------------------------|---------------|
| coordinatesStyleList        | `List<CoordinatesStyle<Enum>>?`  | All coordinates style list.                                       | `null`        |
| axisLabelStyle              | `TextStyle?`                     | Axis label style for the coordinate system.                       | `null`        |
| axisLineColor               | `Color?`                         | Axis line color for the coordinate system.                        | `null`        |
| axisLineWidth               | `double?`                        | Axis line width for the coordinate system.                        | `null`        |
| gridLineColor               | `Color?`                         | Grid line color for the coordinate system.                        | `null`        |
| gridLineWidth               | `double?`                        | Grid line width for the coordinate system.                        | `null`        |
| drawGridLineType            | `DrawGridLineType?`              | The type of grid lines to draw.                                   | `null`        |
| drawGridLineStyle           | `DrawGridLineStyle?`             | The style of grid lines to draw.                                  | `null`        |
| dashedGridLineWidth         | `double?`                        | The unit width of the dashed grid lines.                          | `null`        |
| dashedGridLineGap           | `double?`                        | The gap width of the dashed grid lines.                           | `null`        |
| showTapArea                 | `bool?`                          | Whether to display the user's touch area.                         | `null`        |
| lineWidth                   | `double?`                        | Line width on the all coordinates.                                | `null`        |
| displayValueTextStyle       | `TextStyle?`                     | Text style for display value on the coordinate system.            | `null`        |
| displayValueMarginBottom    | `double?`                        | Margin bottom for display value on the coordinate system.         | `null`        |
| indicatorMarginTop          | `double?`                        | Margin top for check or close indicator on the coordinate system. | `null`        |
| indicatorRadius             | `double?`                        | Radius for check or close indicator on the coordinate system.     | `null`        |
| checkBackgroundColor        | `Color?`                         | Background color for check indicator on the coordinate system.    | `null`        |
| closeBackgroundColor        | `Color?`                         | Background color for close indicator on the coordinate system.    | `null`        |
| checkColor                  | `Color?`                         | Color for check symbol on the coordinate system.                  | `null`        |
| closeColor                  | `Color?`                         | Color for close symbol on the coordinate system.                  | `null`        |
| smooth                      | `double?`                        | Smoothness of the line chart.                                     | `null`        |
| disabledOpacity             | `double?`                        | Opacity when line chart is can't change.                          | `null`        |