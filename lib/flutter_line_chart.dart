library flutter_line_chart;

export 'model/layer.dart';
export 'model/view.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'model/layer.dart';
import 'model/view.dart';
import 'layer_painter.dart';

typedef ViewsValueCallback = void Function(List<int> viewsValue);

class FlutterLineChart<E extends Enum> extends StatefulWidget {
  const FlutterLineChart({
    Key? key,
    required this.layer,
    this.onChange,
    this.onChangeEnd,
  }) : super(key: key);

  final Layer<E> layer;

  final ViewsValueCallback? onChange;

  final ViewsValueCallback? onChangeEnd;

  @override
  State<FlutterLineChart<E>> createState() => _FlutterLineChartState<E>();
}

class _FlutterLineChartState<E extends Enum>
    extends State<FlutterLineChart<E>> {
  View<E>? currentSelectedView;

  Layer<E> get layer => widget.layer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            currentSelectedView = layer.hintTestView(
              layer.adjustLocalPosition(
                details.localPosition,
                chartHeight: chartHeight,
              ),
            );

            if (currentSelectedView != null) {
              HapticFeedback.mediumImpact();
            }
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (currentSelectedView != null) {
              late double dy;

              final double yStep = layer.getYAxisStepOffsetValue(chartHeight);

              if (layer.enforceStepOffset) {
                dy = layer.getWithinRangeYAxisOffsetValue(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yStep: yStep,
                  stepFactor: layer.yAxisStep,
                );

                final double realValue = layer.yAxisOffsetValue2RealValue(
                  dy,
                  yStep: yStep,
                );

                dy = layer.realValue2YAxisOffsetValue(
                  realValue,
                  chartHeight: chartHeight,
                  yStep: yStep,
                  stepFactor: layer.yAxisStep,
                );
              } else {
                dy = layer.getWithinRangeYAxisOffsetValue(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  yStep: yStep,
                );
              }

              currentSelectedView!.offset = Offset(
                currentSelectedView!.offset.dx,
                dy,
              );

              layer.refresh();

              if (layer.currentViewsValue != null) {
                widget.onChange?.call(layer.currentViewsValue!);
              }
            }
          },
          onPanEnd: (DragEndDetails details) {
            currentSelectedView = null;

            if (layer.currentViewsValue != null) {
              widget.onChangeEnd?.call(layer.currentViewsValue!);
            }
          },
          child: CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: ViewPainter<E>(
              layer: widget.layer,
            ),
          ),
        );
      },
    );
  }
}
