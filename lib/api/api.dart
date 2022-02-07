import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models.dart';


final _log = Logger('Api');


const _appid = 'b0b4378f9828e5328a560b664b420b58';


class Api
{
  static Future<WeatherInfo> getWeather(final City city) async
  {
    final queryParametrs = <String, dynamic>{
      'lat': city.coordinates.latitude.toString(),
      'lon': city.coordinates.longitude.toString(),
      'exclude': 'minutely,alerts',
      'appid': _appid,
      'units': 'metric',
    };
    final uri = Uri.http(
      'api.openweathermap.org',
      '/data/2.5/onecall',
      queryParametrs,
    );
    _log.info(uri.toString);
    final response = await http.get(uri);
    final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherInfo.fromJson(data);
  }
}
