import 'package:flutter/widgets.dart';


mixin LoaderState<T extends StatefulWidget> on State<T>
{
  @override
  void setState(VoidCallback fn)
  {
    if (!mounted) return;
    super.setState(fn);
  }

  String? get message => _message;

  set message(final String? value) => setState(()
  {
    _message = value;
  });

  bool get supportVisible => _supportVisible;

  set supportVisible(final bool value) => setState(()
  {
    _supportVisible = value;
  });

  bool get success => _success;

  set success(final bool value) => setState(()
  {
    _success = value;
  });

  String? _message;
  bool _supportVisible = false;
  bool _success = true;
}