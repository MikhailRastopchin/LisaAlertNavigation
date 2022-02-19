import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../models.dart';


final _log = Logger('Storage');


class MapService
  with ChangeNotifier
{
  MapSettings get settings => _settings;

  Future<void> setMap(final MapSettings value) async
  {
    _settings = value;
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
      _settings = MapSettings();
    } else {
      _settings = MapSettings.fromJson(jsonValue);
      _log.info('Map settings loaded from the local storage.');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async
  {
    await saveJson(_settingsPath, _settings);
    _log.info('Map settings saved in the local storage.');
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  late MapSettings _settings;
}
