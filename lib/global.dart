import 'services/app.dart';
import 'services/coordinates.dart';
import 'services/images.dart';



abstract class Global
{
  static late final AppService app;
  static late final CoordinatesService coordinates;
  static late final ImagesService images;

  static void init()
  {
    app = AppService();
    coordinates = CoordinatesService();
    images = const ImagesService();
  }
}
