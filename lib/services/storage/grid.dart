import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../models.dart';


final _log = Logger('Storage');


class GridService
  with ChangeNotifier
{
  bool get showGrid => _showGrid;

  LatLng? get startCoordinate => _startCoordinate;

  double? get gridStep => _gridStep;

  int? get horizontalStepsCount => _horizontalStepsCount;

  int? get verticalStepsCount => _verticalStepsCount;

  Future<void> setShowGrid(final bool value) async
  {
    if (_showGrid == value) return;
    _showGrid = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setStartCoordinate(final LatLng? value) async
  {
    if (_startCoordinate == value) return;
    _startCoordinate = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setGridStep(final double? value) async
  {
    if (_gridStep == value) return;
    _gridStep = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setHorizontalStepsCount(final int? value) async
  {
    if (_horizontalStepsCount == value) return;
    _horizontalStepsCount = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVerticalStepsCount(final int? value) async
  {
    if (_verticalStepsCount == value) return;
    _verticalStepsCount = value;
    await _saveSettings();
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
      _showGrid = false;
    } else {
      final gridSettings = GridSettings.fromJson(jsonValue);
      _showGrid = gridSettings.showGrid;
      _startCoordinate = gridSettings.startCoordinate;
      _gridStep = gridSettings.gridStep;
      _horizontalStepsCount = gridSettings.horizontalStepsCount;
      _verticalStepsCount = gridSettings.verticalStepsCount;
      if (
        _showGrid == true
        && (
          _startCoordinate == null
          || _gridStep == null
          || _horizontalStepsCount == null
          || _verticalStepsCount == null
        )
      ) _showGrid = false;
      _log.info('Grid settings loaded from the local storage.');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async
  {
    final gridSettings = GridSettings(
      showGrid: showGrid,
      startCoordinate: startCoordinate,
      gridStep: gridStep,
      horizontalStepsCount: horizontalStepsCount,
      verticalStepsCount: verticalStepsCount,
    );
    await saveJson(_settingsPath, gridSettings);
    _log.info('Grid settings saved in the local storage.');
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  late bool _showGrid;
  LatLng? _startCoordinate;
  double? _gridStep;
  int? _horizontalStepsCount;
  int? _verticalStepsCount;
}