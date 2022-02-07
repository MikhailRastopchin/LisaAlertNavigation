import 'condition.dart';
import 'temperature.dart';

class DailyForecast
{
  final DateTime forecastedTo;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime moonrise;
  final DateTime moonset;
  final Temperature temperature;
  final Temperature feelsLike;
  final int pressure;
  final int humidity;
  final double dewPoint;
  final double windSpeed;
  final int windDeg;
  final double windGust;
  final List<Condition> weather;
  final int cloudiness;
  final double pop;
  final double uvi;

  DailyForecast({
    required this.forecastedTo,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.temperature,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.weather,
    required this.cloudiness,
    required this.pop,
    required this.uvi
  });

  factory DailyForecast.fromJson(Map<String, dynamic> jsonValue)
  {
    final forecastedTo = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['dt'] as int) * 1000
    );
    final sunrise = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['sunrise'] as int) * 1000
    );
    final sunset = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['sunset'] as int) * 1000
    );
    final moonrise = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['moonrise'] as int) * 1000
    );
    final moonset = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['moonset'] as int) * 1000
    );
    final weather = <Condition>[];
    final jsonConditions = jsonValue['weather'];
    if (jsonConditions is List) {
      for (var jsonCondition in jsonConditions) {
        final condition = Condition.fromJson(jsonCondition);
        weather.add(condition);
      }
    }
    return DailyForecast(
      forecastedTo: forecastedTo,
      sunrise: sunrise,
      sunset: sunset,
      moonrise: moonrise,
      moonset: moonset,
      temperature: Temperature.fromJson(jsonValue['temp']),
      feelsLike: Temperature.fromJson(jsonValue['feels_like']),
      pressure: jsonValue['pressure'],
      humidity: jsonValue['humidity'],
      dewPoint: jsonValue['dew_point'],
      windSpeed: (jsonValue['wind_speed'] as num).toDouble(),
      windDeg: jsonValue['wind_deg'],
      windGust: jsonValue['wind_gust'],
      weather: weather,
      cloudiness: jsonValue['clouds'],
      pop: (jsonValue['pop'] as num).toDouble(),
      uvi: (jsonValue['uvi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson()
    => <String, dynamic>{
      'dt': forecastedTo.millisecondsSinceEpoch / 1000,
      'sunrise': sunrise.millisecondsSinceEpoch / 1000,
      'sunset': sunset.millisecondsSinceEpoch / 1000,
      'moomrise': moonrise.millisecondsSinceEpoch / 1000,
      'moonset': moonset.millisecondsSinceEpoch / 1000,
      'temp': temperature.toJson(),
      'feels_like': feelsLike.toJson(),
      'pressure': pressure,
      'humidity': humidity,
      'dew_point': dewPoint,
      'wind_speed': windSpeed,
      'wind_deg': windDeg,
      'wind_gust':windGust,
      'weather': weather.map((condition) => condition.toJson()).toList(),
      'clouds': cloudiness,
      'pop': pop,
      'uvi': uvi,
    };
}