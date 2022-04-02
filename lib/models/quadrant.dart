import 'package:flutter/material.dart';
import 'package:la_navigation/utils/utm/src/converter.dart';
import 'package:la_navigation/utils/utm/utm.dart';

import 'grid_settings.dart';


class Quadrant
{
  static List<Quadrant> generateQuadrants(final GridSettings settings)
  {
    final converter = UtmConverter(GeodeticSystemType.wgs84);
    final nextZone = converter.latlonToUtm(
      settings.startCoordinate!.lat,
      settings.startCoordinate!.lon + 6,
    );
    var startPoint = settings.startCoordinate!;
    final quadrants = <Quadrant>[];
    for (var indexY = 0; indexY < settings.verticalStepsCount!; indexY++) {
      if (indexY != 0) {
        startPoint = converter.utmToLatLon(
            startPoint.easting,
            startPoint.northing - settings.gridStep!,
            startPoint.zoneNumber,
            startPoint.zoneLetter,
          );
      }
      var startTopLeftPoint = startPoint;
      for (var indexX = 0; indexX < settings.horizontalStepsCount!; indexX++) {
        if (indexX != 0) {
          startTopLeftPoint =  startTopLeftPoint.easting + settings.gridStep! > 1000000
            ? converter.utmToLatLon(
                startTopLeftPoint.easting + settings.gridStep!- 1000000,
                startTopLeftPoint.northing,
                nextZone.zoneNumber,
                nextZone.zoneLetter,
              )
            : converter.utmToLatLon(
                startTopLeftPoint.easting + settings.gridStep!,
                startTopLeftPoint.northing,
                startTopLeftPoint.zoneNumber,
                startTopLeftPoint.zoneLetter,
              );
        }
        final topRightPoint = startTopLeftPoint.easting + settings.gridStep! > 1000000
          ? converter.utmToLatLon(
              startTopLeftPoint.easting + settings.gridStep! - 1000000,
              startTopLeftPoint.northing,
              nextZone.zoneNumber,
              nextZone.zoneLetter,
            )
          : converter.utmToLatLon(
              startTopLeftPoint.easting + settings.gridStep!,
              startTopLeftPoint.northing,
              startTopLeftPoint.zoneNumber,
              startTopLeftPoint.zoneLetter,
            );
        final bottomRightPoint = converter.utmToLatLon(
          topRightPoint.easting,
          topRightPoint.northing - settings.gridStep!,
          topRightPoint.zoneNumber,
          topRightPoint.zoneLetter,
        );
        final bottomLeftPoint = converter.utmToLatLon(
          startTopLeftPoint.easting,
          startTopLeftPoint.northing - settings.gridStep!,
          startTopLeftPoint.zoneNumber,
          startTopLeftPoint.zoneLetter,
        );
        final endTopLeftPoint = startTopLeftPoint;
        final points = [
          startTopLeftPoint,
          topRightPoint,
          bottomRightPoint,
          bottomLeftPoint,
          endTopLeftPoint,
        ];
        quadrants.add(Quadrant(points: points));
      }
    }
    return quadrants;
  }

  final List<UtmCoordinate> points;
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
