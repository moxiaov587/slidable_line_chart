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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            var offset =
                details.localPosition.translate(-widget.layer.scaleHeight, 0);

            currentSelectedView = widget.layer.hintTestView(
              Offset(
                offset.dx,
                offset.dy - height,
              ),
            );

            if (currentSelectedView != null) {
              HapticFeedback.mediumImpact();
            }
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (currentSelectedView != null) {
              currentSelectedView!.offset = Offset(
                currentSelectedView!.offset.dx,
                (details.localPosition.dy - height)
                    .clamp(
                      widget.layer.scaleHeight -
                          height -
                          currentSelectedView!.height / 2,
                      0 - currentSelectedView!.height / 2,
                    )
                    .floorToDouble(),
              );

              setState(() {});
            }
          },
          onPanEnd: (DragEndDetails details) {
            currentSelectedView = null;
          },
          child: CustomPaint(
            size: Size(width, height),
            painter: ViewPainter(
              layer: widget.layer,
            ),
          ),
        );
      },
    );
  }
}
