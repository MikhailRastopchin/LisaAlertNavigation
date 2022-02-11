import 'package:latlong2/latlong.dart';

class GridSettings
{
  final bool showGrid;
  final LatLng? startCoordinate;
  final double? gridStep;
  final int? horizontalStepsCount;
  final int? verticalStepsCount;

  GridSettings({
    this.showGrid = false,
    this.startCoordinate,
    this.gridStep,
    this.horizontalStepsCount,
    this.verticalStepsCount
  });

  factory GridSettings.fromJson(final Map<String, dynamic> jsonValue)
  {
    return GridSettings(
      showGrid: jsonValue['show_grid'],
      startCoordinate: LatLng.fromJson(jsonValue['start_coordinate']),
      gridStep: (jsonValue['grip_step'] as num).toDouble(),
      horizontalStepsCount: jsonValue['horizontal_steps_count'],
      verticalStepsCount: jsonValue['vertical_steps_count'],
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{'show_grid': showGrid};
    if (startCoordinate != null) {
      jsonValue['start_coordinate'] = startCoordinate!.toJson();
    }
    if (gridStep != null) {
      jsonValue['grip_step'] = gridStep;
    }
    if (horizontalStepsCount != null) {
      jsonValue['horizontal_steps_count'] = horizontalStepsCount;
    }
    if (verticalStepsCount != null) {
      jsonValue['vertical_steps_count'] = verticalStepsCount;
    }
    return jsonValue;
  }
}
