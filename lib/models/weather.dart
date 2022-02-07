import 'condition.dart';
import 'rain.dart';
import 'snow.dart';

class Weather
{
  final DateTime date;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double temperature;
  final double feelsLike;
  final int pressure;
  final double dewPoint;
  final int humidity;
  final double uvi;
  final int cloudiness;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double? windGust;
  final List<Condition> weather;
  final double pop;
  final Rain? rain;
  final Snow? snow;

  Weather({
    required this.date,
    this.sunrise,
    this.sunset,
    required this.temperature,
    required this.feelsLike,
    required this.pressure,
    required this.dewPoint,
    required this.humidity,
    required this.uvi,
    required this.cloudiness,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.weather,
    required this.pop,
    this.rain,
    this.snow,
  });

  factory Weather.fromJson(final Map<String, dynamic> jsonValue)
  {
    final date = DateTime.fromMillisecondsSinceEpoch(
      (jsonValue['dt'] as int) * 1000
    );
    DateTime? sunrise;
    final jsonSunrise = jsonValue['sunrise'];
    if (jsonSunrise != null) {
      sunrise = DateTime.fromMillisecondsSinceEpoch((jsonSunrise as int) * 1000);
    }
    DateTime? sunset;
    final jsonSunset = jsonValue['sunset'];
    if (jsonSunset != null) {
      sunset = DateTime.fromMillisecondsSinceEpoch((jsonSunset as int) * 1000);
    }
    final weather = <Condition>[];
    final jsonConditions = jsonValue['weather'];
    if (jsonConditions is List) {
      for (var jsonCondition in jsonConditions) {
        final condition = Condition.fromJson(jsonCondition);
        weather.add(condition);
      }
    }
    Rain? rain;
    final jsonRain = jsonValue['rain'];
    if (jsonRain != null) {
      rain =Rain.fromJson(jsonRain);
    }
    Snow? snow;
    final jsonSnow = jsonValue['snow'];
    if (jsonSnow != null) {
      snow = Snow.fromJson(jsonSnow);
    }
    double? windGust;
    final jsonWindGust = jsonValue['wind_gust'];
    if (jsonWindGust != null) {
      windGust = (jsonWindGust as num).toDouble();
    }

    return Weather(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
      temperature: (jsonValue['temp'] as num).toDouble(),
      feelsLike: (jsonValue['feels_like'] as num).toDouble(),
      pressure: jsonValue['pressure'],
      dewPoint: (jsonValue['dew_point'] as num).toDouble(),
      humidity: jsonValue['humidity'],
      uvi: (jsonValue['uvi'] as num).toDouble(),
      cloudiness: jsonValue['clouds'],
      visibility: jsonValue['visibility'],
      windSpeed: (jsonValue['wind_speed'] as num).toDouble(),
      windDeg: jsonValue['wind_deg'],
      windGust: windGust,
      weather: weather,
      pop: ((jsonValue['pop'] ?? 0).toDouble()),
      rain: rain,
      snow: snow,
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{
      'dt': date.millisecondsSinceEpoch / 1000,
      'temp': temperature,
      'feels_like': feelsLike,
      'pressure': pressure,
      'dew_point':dewPoint,
      'humidity': humidity,
      'uvi': uvi,
      'clouds': cloudiness,
      'visibility': visibility,
      'wind_speed': windSpeed,
      'wind_deg': windDeg,
      'weather': weather.map((condition) => condition.toJson()).toList(),
      'pop': pop,
    };
    if (windGust != null) {
      jsonValue['wind_gust'] = windGust;
    }
    if (sunrise != null) {
      jsonValue['sunrise'] = sunrise!.millisecondsSinceEpoch / 1000;
    }
    if (sunset != null) {
      jsonValue['sunset'] = sunset!.millisecondsSinceEpoch / 1000;
    }
    return jsonValue;
  }
}