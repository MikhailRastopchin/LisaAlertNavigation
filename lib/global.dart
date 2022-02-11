import 'services/app.dart';
import 'services/storage.dart';
import 'services/images.dart';



abstract class Global
{
  static late final AppService app;
  static late final StorageService storage;
  static late final ImagesService images;

  static void init()
  {
    app = AppService();
    storage = StorageService();
    images = const ImagesService();
  }
}
