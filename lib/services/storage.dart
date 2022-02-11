import 'storage/coordinates.dart';
import 'storage/map.dart';


class StorageService
{
  final coordinates = CoordinatesService();
  final map = MapService();

  bool get initialized => _initialized;

  StorageService();

  Future<void> init() async
  {
    await coordinates.init();
    await map.init();
    _initialized = true;
  }

  bool _initialized = false;
}
