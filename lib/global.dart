import 'services/app.dart';
import 'services/images.dart';
import 'services/weather_info.dart';



abstract class Global
{
  static late final AppService app;
  static late final ImagesService images;
  static late final WeatherInfoService weatherInfo;

  static void init()
  {
    app = AppService();
    images = const ImagesService();
    weatherInfo = WeatherInfoService();
  }
}
