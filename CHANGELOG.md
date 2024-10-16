## 1.4.0

- Support custom disabled opacity.
- Support align the first and last points of the chart with both ends when display mode.
- Support drawing grid lines as dotted lines. Now the y-axis can also draw grid lines.

## 1.3.0

- Fix the issue of being unable to respond to touch events when the coordinate point touch area overflows.
- **BREAKING CHANGE**
  - Since the touch area is repaired by filling inward, this update may affect the original chart style. Please check and confirm after the update.

## 1.2.0

- Add reverse initialization animation to clean up the chart.
- Add `clearChart` example.
- Fix a comment issue.

## 1.1.1

- Add `enableFeedback` parameter.
- Add animation effects to coordinate points.

## 1.1.0

- Improve curve chart display.
- Constraint plugin generic type should be an enum.
- Add color palette to optimize display when no theme is set.
- Add the simplest example usage.
- Fix an issue where the opacity of some colors could be overridden.
- **BREAKING CHANGE**
  - Refactor `curved` to `smooth`, now use `smooth` to set smoothness.
  - Remove `defaultCoordinatePointColor`, `defaultTapAreaColor` and `defaultFillAreaColor`, now if these styles are not set, they will be set based on the coordinate point color.

## 1.0.2

- Support display as a curve chart.

## 1.0.1

- Improve performance of drag events.
- Optimize the drawing of coordinate systems.

## 1.0.0

- Improve that animation effect of chart initialization.
- Optimized sliding calculation method.
- Export `SlidableLineChartState` to provide `resetAnimationController`.
- Update example to provide more use cases.
- **BREAKING CHANGE**
  - Now the diagram itself doesn't maintain any state and needs to be updated via the `onChanged` callback.
  - Remove the style-related property from the `SlidableLineChart` and now replace it with `SlidableLineChartThemeData`.
  - Use `coordinatesOptionsList` instead of `allCoordinates` to simplify parameter entry.
  - Rename `canDragCoordinateType` to `slidableCoordinateType`.
  - Rename `yAxisDivisions` to `divisions`.
  - Use `slidePrecision` instead of `enforceStepOffset` to set the minimum value for each slide by the user.
  - Rename `reversedYAxis` to `reversed`.
  - Rename `onlyRenderEvenYAxisText` to `onlyRenderEvenAxisLabel`.
  - Rename `drawCheckOrClose` to `onDrawCheckOrClose`.

## 0.1.1

- Add .pubignore.

## 0.1.0

- Initial plugin release.
