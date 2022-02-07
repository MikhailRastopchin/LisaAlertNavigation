import 'package:flutter/material.dart';

import '../settings.dart';


class SettingsView extends StatefulWidget
{
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}


class _SettingsViewState extends State<SettingsView>
  with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context)
  {
    super.build(context);
    return const DailyForecastPage();
  }
}
