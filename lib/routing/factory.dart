import 'package:flutter/material.dart';

import '../pages/home.dart';
import '../pages/loader.dart';
import '../pages/loader_state.dart';
import 'routes.dart';


class UnknownRouteException implements Exception
{
  final String? route;

  const UnknownRouteException(this.route);

  @override
  String toString() => 'Could not dispatch the route $route';
}


typedef PageBuilder = Widget Function();


class RoutesFactory
{
  final Function(LoaderState) onLoading;

  const RoutesFactory(this.onLoading);

  Route<dynamic> call(final RouteSettings settings)
  {
    switch (settings.name) {
      case Routes.loader:
        return getGenericRoute(settings, () => LoaderPage(onLoading));
      case Routes.home:
        return getGenericRoute(settings,
          () => const HomePage()
        );
    }
    throw(UnknownRouteException(settings.name));
  }

  Route<T> getGenericRoute<T>(
    final RouteSettings settings,
    final PageBuilder builder,
  )
  {
    return MaterialPageRoute<T>(
      builder: (context) => builder(),
      settings: settings,
    );
  }
}
