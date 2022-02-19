import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../models.dart';


final _log = Logger('Storage');


class GridService
  with ChangeNotifier
{
  GridSettings get settings => _settings;

  Future<void> setGrid(final GridSettings value) async
  {
    _settings = value;
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
      _settings = GridSettings();
    } else {
      _settings = GridSettings.fromJson(jsonValue);
      _log.info('Grid settings loaded from the local storage.');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async
  {
    await saveJson(_settingsPath, _settings);
    _log.info('Grid settings saved in the local storage.');
  }

  String get _settingsPath => '$_storagePath/settings.json';

  late final String _storagePath;

  late GridSettings _settings;
}