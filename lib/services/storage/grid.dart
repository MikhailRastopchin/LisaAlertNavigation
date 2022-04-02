import 'package:flutter/foundation.dart';
import 'package:la_navigation/utils/utm/src/converter.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../utils/grid_label_character.dart';
import '../../models.dart';
import '../../utils/utm/utm.dart';


final _log = Logger('Storage');


class GridService
  with ChangeNotifier
{
  GridSettings get settings => _settings;

  List<Quadrant>? get quadrants => _quadrants;

  Map<String, UtmCoordinate>? get gridPoints => _gridPoints;

  Future<void> setGrid(final GridSettings value) async
  {
    _settings = value;
    await _saveSettings();
    if (_settings.showGrid) {
      if (settings.useUTM) {
          final utmNode = _findNearestUTMNode(
            _settings.startCoordinate!,
            _settings.gridStep!.toInt()
          );
          _settings = _settings.copyWith(startCoordinate: utmNode);
        }
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
        if (settings.useUTM) {
          final utmNode = _findNearestUTMNode(
            _settings.startCoordinate!,
            _settings.gridStep!.toInt()
          );
          _settings = _settings.copyWith(startCoordinate: utmNode);
        }
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

  Map<String, UtmCoordinate> _generateGridPoints(final GridSettings settings)
  {
    final converter = UtmConverter(GeodeticSystemType.wgs84);
    final nextZone = converter.latlonToUtm(
      settings.startCoordinate!.lat,
      settings.startCoordinate!.lon + 6,
    );
    final points = <String, UtmCoordinate>{};
    var startPoint = settings.startCoordinate!;
    for (var indexY = 1; indexY <= settings.verticalStepsCount! + 1; indexY++) {
      if (indexY != 1) {
        startPoint = converter.utmToLatLon(
          settings.startCoordinate!.easting,
          settings.startCoordinate!.northing - settings.gridStep! * (indexY - 1),
          settings.startCoordinate!.zoneNumber,
          settings.startCoordinate!.zoneLetter,
        );
      }
      for (
        var indexX = 1;
        indexX <= settings.horizontalStepsCount! + 1;
        indexX++
      ) {
        final currentPoint = indexX == 1
          ? startPoint
          : startPoint.easting + settings.gridStep! * (indexX - 1) > 1000000
            ? converter.utmToLatLon(
                startPoint.easting + settings.gridStep! * (indexX - 1) - 1000000,
                startPoint.northing,
                nextZone.zoneNumber,
                nextZone.zoneLetter,
              )
            : converter.utmToLatLon(
                startPoint.easting + settings.gridStep! * (indexX - 1),
                startPoint.northing,
                startPoint.zoneNumber,
                startPoint.zoneLetter,
              );
        final columnLabel = getColumnLabel(indexX);
        final label = '$columnLabel$indexY';
        points[label] = currentPoint;
      }
    }
    return points;
  }

  UtmCoordinate _findNearestUTMNode(final UtmCoordinate current, final int gridStep)
  {
    final converter = UtmConverter(GeodeticSystemType.wgs84);
    if (
      current.easting % gridStep == 0
      && current.northing % gridStep == 0
    ) return current;
    final northing =  current.northing
      - (current.northing % gridStep)
      + gridStep;
    final easting = current.easting
      - (current.easting % gridStep);
    if (easting < 0) {
      final previosZone = converter.latlonToUtm(
        current.lat,
        current.lon - 6,
      );
      return converter.utmToLatLon(
        1000000 - easting.abs(),
        northing,
        previosZone.zoneNumber,
        previosZone.zoneLetter,
      );
    } else {
      return converter.utmToLatLon(
        easting,
        northing,
        current.zoneNumber,
        current.zoneLetter,
      );
    }
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  late GridSettings _settings;

  List<Quadrant>? _quadrants;
  Map<String, UtmCoordinate>? _gridPoints;
}