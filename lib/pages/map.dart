import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:la_navigation/pages/map/coordinate_dialog.dart';
import 'package:la_navigation/plugins/grid.dart';
import 'package:la_navigation/services/storage/grid.dart';
import 'package:la_navigation/utils/utm/src/constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/storage/coordinates.dart';
import '../services/storage/map.dart';
import '../plugins/zoombuttons.dart';
import '../plugins/current_location_button.dart';
import '../models.dart';
import 'common/styles.dart';


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
    _coordinates = context.read<CoordinatesService>();
    _mapService = context.read<MapService>();
    _gridService = context.read<GridService>();
    _coordinates.addListener(_rebuild);
    _mapService.addListener(_rebuild);
    _gridService.addListener(_rebuild);
  }

  @override
  void dispose()
  {
    _coordinates.removeListener(_rebuild);
    _mapService.removeListener(_rebuild);
    _gridService.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Карта'), centerTitle: true),
      body: _coordinates.ownCoordinate == null ? null :content,
    );
  }

  Widget get content
  {
    final tileLayerOptions = _mapService.settings.useLocalMap
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
    Map<String, UtmCoordinate> gridPoints = {};
    if (_gridService.settings.showGrid) {
      quadrants = _gridService.quadrants!;
      gridPoints = _gridService.gridPoints!;
    }
    final markers = <Marker>[];
    final polilines = <Polyline>[];
    if (_coordinates.showOwnTrack) {
      polilines.add(_buildPoliline(_coordinates.ownTrack, Colors.red));
    }
    for (var index = 0; index < _coordinates.tracks.length; index++) {
      final dividedIndex = index > 9 ? index % 10 : index;
      assert(dividedIndex < kMarkerColors.length);
      final color = kMarkerColors[dividedIndex];
      final track = _coordinates.tracks[index];
      markers.add(_buildMarker(track, color));
      polilines.add(_buildPoliline(track, color));
    }
    final ownMarker = _buildOwnMarker(
      _coordinates.ownCoordinate!,
      _coordinates.oldOwnCoordinate ?? _coordinates.ownCoordinate!,
    );
    final gridMarkers = gridPoints.entries
      .map((point) => _buildGridMarker(
        label: point.key,
        coordinate: point.value,
        showAsUTM: _gridService.settings.useUTM,
      ));
    markers.addAll(gridMarkers);
    markers.add(ownMarker);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _coordinates.ownCoordinate,
        zoom: 18.0,
        plugins: [
          if (_gridService.settings.showGrid) GridLayerPlugin(),
          ZoomButtonsPlugin(),
          CurrentLocationButtonPlugin(),
        ],
      ),
      layers: [
        tileLayerOptions,
        if (_gridService.settings.showGrid) GridLayerPluginOption(
          quadrants: quadrants
        ),
        PolylineLayerOptions(polylines: polilines),
        MarkerLayerOptions(markers: markers),
      ],
      nonRotatedLayers: [
        CurrentLocationButtonPluginOption(
          controller: _mapController,
          targetLocation: _coordinates.ownCoordinate!,
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
    required final UtmCoordinate coordinate,
    required final bool showAsUTM,
  })
  {
    const labelHeight = 14.0;
    const maxLabelWidth = 50.0;
    final theme = Theme.of(context);
    return Marker(
      key: ValueKey(coordinate),
      width: maxLabelWidth,
      height: maxLabelWidth,
      point: LatLng(coordinate.lat, coordinate.lon),
      rotate: true,
      builder: (context) => InkWell(
        onTap: () => _showCoordinateInfo(coordinate: coordinate, label: label),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(
            minHeight: labelHeight,
            minWidth: labelHeight,
            maxWidth: maxLabelWidth,
            maxHeight: maxLabelWidth,
          ),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(labelHeight / 2),
                color: AppStyle.liteColors.primaryColor
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.subtitle2!.copyWith(color: Colors.amber),
                overflow: TextOverflow.ellipsis,
              ),
          ),
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

  Future<void> _showCoordinateInfo({
    required final UtmCoordinate coordinate,
    required final String label,
  }) async
  {
    await showDialog(
      context: context,
      builder: (context) => CoordinateDialog(
        coordinate: coordinate,
        label: label,
      ),
    );
  }

  void _rebuild() => setState(() {});

  late final MapController _mapController;

  late final CoordinatesService _coordinates ;
  late final MapService _mapService;
  late final GridService _gridService;
}
