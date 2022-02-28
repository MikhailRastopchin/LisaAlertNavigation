import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../utils/grid_label_character.dart';
import '../../utils/scale_converter.dart';
import '../../models.dart';


final _log = Logger('Storage');


class GridService
  with ChangeNotifier
{
  GridSettings get settings => _settings;

  List<Quadrant>? get quadrants => _quadrants;

  Map<String, LatLng>? get gridPoints => _gridPoints;

  Future<void> setGrid(final GridSettings value) async
  {
    _settings = value;
    await _saveSettings();
    if (_settings.showGrid) {
      _quadrants = Quadrant.generateQuadrants(_settings);
      _gridPoints = _generateGridPoints(_settings);
    }
    notifyListeners();
  }

  Future<void> init() async
  {
    _storagePath = await getFilesPath(path: 'grid_settings', create: true);
    await _loadSettings();
  }

  Future<void> _loadSettings() async
  {
    final jsonValue = await loadJson(_settingsPath);
    if (jsonValue == null) {
      _log.info('No grid settings in the local storage.');
      _settings = GridSettings();
    } else {
      _settings = GridSettings.fromJson(jsonValue);
      if (_settings.showGrid) {
        _quadrants = Quadrant.generateQuadrants(_settings);
        _gridPoints = _generateGridPoints(_settings);
      }
      _log.info('Grid settings loaded from the local storage.');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async
  {
    await saveJson(_settingsPath, _settings);
    _log.info('Grid settings saved in the local storage.');
  }

  Map<String, LatLng> _generateGridPoints(final GridSettings settings)
  {
    final points = <String, LatLng>{};
    var startPoint = settings.startCoordinate!;
    for (var indexY = 1; indexY <= settings.verticalStepsCount! + 1; indexY++) {
      if (indexY != 1) {
        startPoint = calculateEndingGlobalCoordinates(
          settings.startCoordinate!, 180, settings.gridStep! * (indexY - 1)
        );
      }
      for (
        var indexX = 1;
        indexX <= settings.horizontalStepsCount! + 1;
        indexX++
      ) {
        final currentPoint = indexX == 1
          ? startPoint
          :  calculateEndingGlobalCoordinates(
              startPoint, 90, settings.gridStep! * (indexX - 1)
            );
        final columnLabel = getColumnLabel(indexX);
        final label = '$columnLabel$indexY';
        points[label] = currentPoint;
      }
    }
    return points;
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  late GridSettings _settings;

  List<Quadrant>? _quadrants;
  Map<String, LatLng>? _gridPoints;
}