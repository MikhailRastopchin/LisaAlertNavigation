import 'package:la_navigation/utils/utm/utm.dart';

class GridSettings
{
  final bool showGrid;
  final bool useUTM;
  final UtmCoordinate? startCoordinate;
  final double? gridStep;
  final int? horizontalStepsCount;
  final int? verticalStepsCount;

  GridSettings({
    this.showGrid = false,
    this.useUTM = false,
    this.startCoordinate,
    this.gridStep,
    this.horizontalStepsCount,
    this.verticalStepsCount
  }) : assert(
    showGrid == false
    || (
      startCoordinate != null
      && gridStep != null
      && horizontalStepsCount != null
      && verticalStepsCount != null
    )
  );

  factory GridSettings.fromJson(final Map<String, dynamic> jsonValue)
  {
    return GridSettings(
      showGrid: jsonValue['show_grid'],
      useUTM: jsonValue['use_UTM'],
      startCoordinate: UtmCoordinate.fromJson(jsonValue['start_coordinate']),
      gridStep: (jsonValue['grip_step'] as num).toDouble(),
      horizontalStepsCount: jsonValue['horizontal_steps_count'],
      verticalStepsCount: jsonValue['vertical_steps_count'],
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{
      'show_grid': showGrid,
      'use_UTM': useUTM,
    };
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

  GridSettings copyWith({
    final bool? showGrid,
    final bool? useUTM,
    final UtmCoordinate? startCoordinate,
    final double? gridStep,
    final int? horizontalStepsCount,
    final int? verticalStepsCount,
  })
  {
    return GridSettings(
      showGrid: showGrid ?? this.showGrid,
      useUTM: useUTM ?? this.useUTM,
      startCoordinate: startCoordinate ?? this.startCoordinate,
      gridStep: gridStep ?? this.gridStep,
      horizontalStepsCount: horizontalStepsCount ?? this.horizontalStepsCount,
      verticalStepsCount: verticalStepsCount ?? this.verticalStepsCount,
    );
  }
}
