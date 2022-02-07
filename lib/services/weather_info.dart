import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../global.dart';
import '../models.dart';
import '../routing.dart';


final _log = Logger('WeatherInfoService');


class WeatherInfoService extends ChangeNotifier
{
  bool get isLoading => _isLoading;

  WeatherInfo? get info => _info;

  Future<void> getWeather(final City city) async
  {
    _isLoading = true;
    _info = null;
    notifyListeners();
    try {
      _info = await Api.getWeather(city);
      notifyListeners();
    } catch (e) {
      _log.warning(e);
      Routing.showToast('Ошибка загрузки данных о погоде');
    }
    _isLoading = false;
    notifyListeners();
  }

  bool _isLoading = false;

  WeatherInfo? _info;
}


class WeatherInfoScope extends StatelessWidget
{
  final Widget child;

  const WeatherInfoScope({ final Key? key, required this.child }) : super(key: key);

  @override
  Widget build(final BuildContext context)
  {
    return ChangeNotifierProvider<WeatherInfoService>(
      create: (_) => Global.weatherInfo,
      child: child,
    );

  }
}
