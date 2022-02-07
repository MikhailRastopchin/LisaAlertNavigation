import 'dart:async';

import 'package:flutter/widgets.dart';


class AppService
  with ChangeNotifier
{
  AppLifecycleState? get state => _state;

  set state(AppLifecycleState? value)
  {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  bool get isActive =>
    [ AppLifecycleState.resumed, AppLifecycleState.inactive ].contains(_state);

  bool get isInactive =>
    _state == null ||
    [ AppLifecycleState.paused, AppLifecycleState.detached ].contains(_state);

  Future<void> get loading => _loading.future;

  bool get loaded => _loading.isCompleted;

  void setLoaded() => loaded ? null : _loading.complete();

  AppLifecycleState? _state;

  final _loading = Completer<void>();
}
