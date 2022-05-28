library flutter_line_chart;

export 'model/layer.dart';
export 'model/view.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'model/layer.dart';
import 'model/view.dart';
import 'layer_painter.dart';

class FlutterLineChart extends StatefulWidget {
  const FlutterLineChart({
    Key? key,
    required this.layer,
  }) : super(key: key);

  final Layer layer;

  @override
  State<FlutterLineChart> createState() => _FlutterLineChartState();
}

class _FlutterLineChartState extends State<FlutterLineChart> {
  View? currentSelectedView;

  Layer get layer => widget.layer;

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

              if (layer.enforceStepOffset) {
                dy = layer.getWithinRangeYAxisOffsetValue(
                  details.localPosition.dy,
                  chartHeight: chartHeight,
                  stepFactor: layer.yAxisStep,
                );

                final double yStep = layer.getYAxisStepOffsetValue(chartHeight);

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
                );
              }

              currentSelectedView!.offset = Offset(
                currentSelectedView!.offset.dx,
                dy,
              );

              setState(() {});
            }
          },
          onPanEnd: (DragEndDetails details) {
            currentSelectedView = null;
          },
          child: CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: ViewPainter(
              layer: widget.layer,
            ),
          ),
        );
      },
    );
  }
}
