## 1.0.1

- Improve performance of drag events.
- Optimize the drawing of coordinate systems.

## 1.0.0

- Improve that animation effect of chart initialization.
- Optimized sliding calculation method.
- Export `SlidableLineChartState` to provide `resetAnimationController`.
- Update example to provide more use cases.
-  **BREAKING CHANGE**
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
