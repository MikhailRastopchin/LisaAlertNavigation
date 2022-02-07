import 'coordinates.dart';
import 'daily_forecast.dart';
import 'weather.dart';

class WeatherInfo
{
  final Coordinates coordinates;
  final String timeZone;
  final Duration timeZoneOffset;
  final Weather currentWeather;
  final List<Weather> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  WeatherInfo({
    required this.coordinates,
    required this.timeZone,
    required this.timeZoneOffset,
    required this.currentWeather,
    required this.hourlyForecasts,
    required this.dailyForecasts
  });

  factory WeatherInfo.fromJson(final Map<String, dynamic> jsonValue)
  {
    final coordinates = Coordinates(
      latitude: jsonValue['lat'],
      longitude: jsonValue['lon']
    );
    final hourlyForecasts = <Weather>[];
    final jsonHourlyForecasts = jsonValue['hourly'];
    if (jsonHourlyForecasts is List) {
      for (var jsonHourlyForecast in jsonHourlyForecasts) {
        final hourlyForecast = Weather.fromJson(jsonHourlyForecast);
        hourlyForecasts.add(hourlyForecast);
      }
    }
    final dailyForecasts = <DailyForecast>[];
    final jsonDaylyForecasts = jsonValue['daily'];
    if (jsonDaylyForecasts is List) {
      for (var jsonDailyForecast in jsonDaylyForecasts) {
        final dailyForecast = DailyForecast.fromJson(jsonDailyForecast);
        dailyForecasts.add(dailyForecast);
      }
    }
    return WeatherInfo(
      coordinates: coordinates,
      timeZone: jsonValue['timezone'],
      timeZoneOffset: Duration(seconds: jsonValue['timezone_offset']),
      currentWeather: Weather.fromJson(jsonValue['current']),
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  Map<String, dynamic> toJson()
    => <String, dynamic>{
      'lat': coordinates.latitude,
      'lon': coordinates.longitude,
      'timezone': timeZone,
      'timezone_offset': timeZoneOffset.inSeconds,
      'hourly': hourlyForecasts.map((forecast) => forecast.toJson()).toList(),
      'daily': dailyForecasts.map((forecast) => forecast.toJson()).toList(),
    };
}