import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/coordinates.dart';
import '../widgets/zoombuttons.dart';
import '../widgets/current_location_button.dart';
import '../models.dart';
import 'common/styles.dart';


const _kMarkerColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellowAccent,
  Colors.purple,
  Colors.orange,
  Colors.brown,
  Colors.indigo,
  Colors.lightBlue,
  Colors.teal
];


class MapPage extends StatefulWidget
{
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}


class _MapPageState extends State<MapPage>
  with TickerProviderStateMixin
{
  @override
  void initState()
  {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context)
  {
    final coordinates = context.watch<CoordinatesService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Карта'), centerTitle: true),
      body: coordinates.ownCoordinate == null ? null :content,
    );
  }

  Widget get content
  {
    final coordinates = context.watch<CoordinatesService>();
    final markers = <Marker>[];
    final polilines = <Polyline>[];
    for (var index = 0; index < coordinates.tracks.length; index++) {
      final dividedIndex = index > 9 ? index % 10 : index;
      assert(dividedIndex < _kMarkerColors.length);
      final color = _kMarkerColors[dividedIndex];
      final track = coordinates.tracks[index];
      markers.add(_buildMarker(track, color));
      polilines.add(_buildPoliline(track, color));
    }
    final ownMarker = _buildOwnMarker(
      coordinates.ownCoordinate!,
      coordinates.oldOwnCoordinate ?? coordinates.ownCoordinate!,
    );
    markers.add(ownMarker);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: coordinates.ownCoordinate,
        zoom: 18.0,
        plugins: [
          ZoomButtonsPlugin(),
          CurrentLocationButtonPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: markers),
        PolylineLayerOptions(polylines: polilines),
      ],
      nonRotatedLayers: [
        CurrentLocationButtonPluginOption(
          controller: _mapController,
          targetLocation: coordinates.ownCoordinate!,
          padding: 10.0,
          alignment: const Alignment(1.0, 0.5),
          iconColor: AppStyle.liteColors.headerTextColor,
        ),
        ZoomButtonsPluginOption(
          minZoom: 2,
          maxZoom: 18,
          padding: 10,
          alignment: Alignment.bottomRight,
          zoomInColorIcon: AppStyle.liteColors.headerTextColor,
          zoomOutColorIcon: AppStyle.liteColors.headerTextColor,
        ),
      ],
    );
  }

  Marker _buildMarker(final AnotherFoxTrack track, final Color color)
  {
    final theme = Theme.of(context);
    return Marker(
      key: ValueKey(track.currentCoordinate),
      width: 120,
      height: 30.0,
      point: track.currentCoordinate,
      anchorPos: AnchorPos.exactly(Anchor(105.0, 0.0)),
      builder: (context) => Row(
        children: [
          Icon(Icons.location_on, color: color, size: 30.0),
          const SizedBox(width: 3.0),
          SizedBox(
            width: 77.0,
            child: Text(track.name, style: theme.textTheme.bodyText2!.copyWith(
              color: color
            )),
          ),
        ],
      ),
    );
  }

  Polyline _buildPoliline(final AnotherFoxTrack track, final Color color)
  {
    final points = track.track.values.toList();
    return Polyline(points: points, strokeWidth: 4.0, color: color);
  }

  Marker _buildOwnMarker(
    final LatLng currentCoordinate,
    final LatLng oldCoordinate,
  )
  {
    final height = currentCoordinate.latitude - oldCoordinate.latitude;
    final width = currentCoordinate.longitude - oldCoordinate.longitude;
    final tan = height / width;
    final angle = atan(tan);
    return Marker(
      width: 50.0,
      height: 50.0,
      point: currentCoordinate,
      rotate: true,
      builder: (context) => Transform.rotate(
        angle: angle,
        child: Stack(children: const [
          Icon(Icons.navigation, color: Colors.red, size: 50.0),
          Center(child: Icon(Icons.navigation, color: Colors.amber, size: 30.0)),
        ]),
      ),
    );
  }

  late final MapController _mapController;
}
