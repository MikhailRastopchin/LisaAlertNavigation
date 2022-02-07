import 'package:flutter/material.dart';

import '../map.dart';


class MapView extends StatefulWidget
{
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}


class _MapViewState extends State<MapView>
  with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context)
  {
    super.build(context);
    return const MapPage();
  }
}
