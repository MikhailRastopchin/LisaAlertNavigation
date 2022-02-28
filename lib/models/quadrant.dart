import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../utils/scale_converter.dart';
import 'grid_settings.dart';


class Quadrant
{
  static List<Quadrant> generateQuadrants(final GridSettings settings)
  {
    final quadrants = <Quadrant>[];
    var startPoint = settings.startCoordinate!;
    for (var indexY = 1; indexY <= settings.verticalStepsCount!; indexY++) {
      if (indexY != 1) {
        startPoint = calculateEndingGlobalCoordinates(
          settings.startCoordinate!, 180, settings.gridStep! * (indexY - 1)
        );
      }
      for (var indexX = 1; indexX <= settings.horizontalStepsCount!; indexX++) {
        final startTopLeftPoint = startPoint;
        final topRightPoint = calculateEndingGlobalCoordinates(
          startPoint, 90, settings.gridStep!
        );
        final bottomRightPoint = calculateEndingGlobalCoordinates(
          topRightPoint, 180, settings.gridStep!
        );
        final bottomLeftPoint = calculateEndingGlobalCoordinates(
          bottomRightPoint, -90, settings.gridStep!
        );
        final endTopLeftPoint = calculateEndingGlobalCoordinates(
          bottomLeftPoint, 0, settings.gridStep!
        );
        final points = [
          startTopLeftPoint,
          topRightPoint,
          bottomRightPoint,
          bottomLeftPoint,
          endTopLeftPoint,
        ];
        quadrants.add(Quadrant(points: points));
        startPoint = topRightPoint;
      }
    }
    return quadrants;
  }

  final List<LatLng> points;
  final List<Offset> offsets = [];
  final double lineWidth;
  final TextStyle? labelStyle;
  final Color color;

  Quadrant({
    required this.points,
    this.lineWidth = 1.0,
    this.labelStyle = const TextStyle(color: Colors.amber, fontSize: 12),
    this.color = const Color(0xff000000),
  });
}
