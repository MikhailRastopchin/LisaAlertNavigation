import 'storage/coordinates.dart';
import 'storage/compass.dart';
import 'storage/grid.dart';
import 'storage/map.dart';


class StorageService
{
  final coordinates = CoordinatesService();
  final grid = GridService();
  final map = MapService();
  final compass = CompassService();

  bool get initialized => _initialized;

  StorageService();

  Future<void> init() async
  {
    await coordinates.init();
    await map.init();
    await grid.init();
    await compass.init();
    _initialized = true;
  }

  bool _initialized = false;
}
