// ignore_for_file: prefer_void_to_null

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import '../models.dart';

class GridLayerPluginOption extends LayerOptions
{
  final List<Quadrant> quadrants;

  GridLayerPluginOption({
    final Key? key,
    required this.quadrants,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}


class GridLayerPlugin implements MapPlugin
{
  @override
  Widget createLayer(
    LayerOptions options, MapState mapState, Stream<Null> stream
  )
  {
    if (options is GridLayerPluginOption) {
      return QuadrantLayerWidget(options: options);
    }
    throw Exception('Unknown options type for ScaleLayerPlugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is GridLayerPluginOption;
  }
}


class QuadrantLayerWidget extends StatelessWidget
{
  final GridLayerPluginOption options;

  const QuadrantLayerWidget({Key? key, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.maybeOf(context)!;
    return QuadrantLayer(
      options: options,
      mapState: mapState,
      stream: mapState.onMoved,
    );
  }
}


class QuadrantLayer extends StatelessWidget {
  final GridLayerPluginOption options;
  final MapState mapState;
  final Stream<Null>? stream;

  QuadrantLayer({
    required this.options,
    required this.mapState,
    this.stream
  })
      : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return StreamBuilder<void>(
      stream: stream, // a Stream<void> or null
      builder: (BuildContext context, _) {
        final quadrants = <Widget>[];
        for (var quadrant in options.quadrants) {
          quadrant.offsets.clear();

          _fillOffsets(quadrant.offsets, quadrant.points);
          quadrants.add(CustomPaint(
            painter: QuadrantPainter(quadrant),
            size: size,
          ));
        }

        return Stack(
          children: quadrants,
        );
      },
    );
  }

  void _fillOffsets(final List<Offset> offsets, final List<LatLng> points) {
    for (var i = 0, len = points.length; i < len; ++i) {
      var point = points[i];

      var pos = mapState.project(point);
      pos = pos.multiplyBy(mapState.getZoomScale(mapState.zoom, mapState.zoom)) -
          mapState.getPixelOrigin();
      offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      if (i > 0) {
        offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      }
    }
  }
}


class QuadrantPainter extends CustomPainter {
  final Quadrant quadrant;

  QuadrantPainter(this.quadrant);

  @override
  void paint(Canvas canvas, Size size) {
    if (quadrant.offsets.isEmpty) {
      return;
    }
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = Paint()
      ..strokeWidth = quadrant.lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter
      ..blendMode = BlendMode.srcOver
      ..color = quadrant.color;

    paint.style = PaintingStyle.stroke;
    canvas.saveLayer(rect, Paint());
    _paintLine(canvas, quadrant.offsets, paint);
    canvas.restore();
  }

  void _paintLine(Canvas canvas, List<Offset> offsets, Paint paint) {
    if (offsets.isNotEmpty) {
      final path = ui.Path()..moveTo(offsets[0].dx, offsets[0].dy);
      for (var offset in offsets) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(QuadrantPainter oldDelegate) => false;
}
