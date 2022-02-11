import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../models.dart';


final _log = Logger('Storage');


class MapService
  with ChangeNotifier
{
  bool get useLocalMap => _useLocalMap;

  LatLng? get swPanBoundary => _swPanBoundary;

  LatLng? get nePanBoundary => _nePanBoundary;

  Future<void> setUseLocalMap(final bool value) async
  {
    if (_useLocalMap == value) return;
    _useLocalMap = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSwPanBoundary(final LatLng? value) async
  {
    if (_swPanBoundary == value) return;
    _swPanBoundary = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setNePanBoundary(final LatLng? value) async
  {
    if (_nePanBoundary == value) return;
    _nePanBoundary = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> init() async
  {
    _storagePath = await getFilesPath(path: 'map_settings', create: true);
    await _loadSettings();
  }

  Future<void> _loadSettings() async
  {
    final jsonValue = await loadJson(_settingsPath);
    if (jsonValue == null) {
      _log.info('No map settings in the local storage.');
      _useLocalMap = false;
    } else {
      final mapSettings = MapSettings.fromJson(jsonValue);
      _useLocalMap = mapSettings.useLocalMap;
      _swPanBoundary = mapSettings.swPanBoundary;
      _nePanBoundary = mapSettings.nePanBoundary;
      _log.info('Map settings loaded from the local storage.');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async
  {
    final mapSettings = MapSettings(
      useLocalMap: useLocalMap,
      swPanBoundary: swPanBoundary,
      nePanBoundary: nePanBoundary,
    );
    await saveJson(_settingsPath, mapSettings);
    _log.info('Map settings saved in the local storage.');
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  LatLng? _swPanBoundary;
  LatLng? _nePanBoundary;
  late bool _useLocalMap;
}
