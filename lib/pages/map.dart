import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:la_navigation/plugins/grid.dart';
import 'package:la_navigation/services/storage/grid.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/storage/coordinates.dart';
import '../services/storage/map.dart';
import '../plugins/zoombuttons.dart';
import '../plugins/current_location_button.dart';
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
    final mapService = context.watch<MapService>();
    final gridService = context.watch<GridService>();
    final tileLayerOptions = mapService.settings.useLocalMap
      ? TileLayerOptions(
          urlTemplate: "/storage/emulated/0/tiles/map/{z}/{x}/{y}.png",
          tileProvider: const FileTileProvider(),
        )
      : TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          tileProvider: NetworkTileProvider(),
        );
    List<Quadrant> quadrants = [];
    Map<String, LatLng> gridPoints = {};
    if (gridService.settings.showGrid) {
      quadrants = gridService.quadrants!;
      gridPoints = gridService.gridPoints!;
    }
    final markers = <Marker>[];
    final polilines = <Polyline>[];
    if (coordinates.showOwnTrack) {
      polilines.add(_buildPoliline(coordinates.ownTrack, Colors.red));
    }
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
    final gridMarkers = gridPoints.entries
      .map((point) => _buildGridMarker(
        label: point.key,
        coordinate: point.value
      ));
    markers.addAll(gridMarkers);
    markers.add(ownMarker);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: coordinates.ownCoordinate,
        zoom: 18.0,
        plugins: [
          if (gridService.settings.showGrid) GridLayerPlugin(),
          ZoomButtonsPlugin(),
          CurrentLocationButtonPlugin(),
        ],
      ),
      layers: [
        tileLayerOptions,
        if (gridService.settings.showGrid) GridLayerPluginOption(
          quadrants: quadrants
        ),
        PolylineLayerOptions(polylines: polilines),
        MarkerLayerOptions(markers: markers),
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
      rotate: true,
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

  Marker _buildGridMarker({
    required final String label,
    required final LatLng coordinate,
  })
  {
    const labelSize = 14.0;
    return Marker(
      key: ValueKey(coordinate),
      width: 30,
      height: labelSize,
      point: coordinate,
      rotate: true,
      builder: (context) => Tooltip(
        message: 'Широта: ${coordinate.latitude}, долгота: ${coordinate.longitude}',
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(labelSize / 2),
            color: Colors.black
          ),
          constraints: const BoxConstraints(
            minHeight: labelSize,
            minWidth: labelSize,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(label, style: const TextStyle(color: Colors.amber)),
        ),
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
