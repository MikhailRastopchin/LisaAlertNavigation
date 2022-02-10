import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:la_navigation/models/another_fox_track.dart';
import 'package:la_navigation/services/coordinates.dart';
import 'package:provider/provider.dart';

import '../widgets/zoombuttons.dart';


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
{
  @override
  Widget build(BuildContext context)
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
    return Scaffold(
      appBar: AppBar(title: const Text('Карта'), centerTitle: true),
      body: FlutterMap(
        options: MapOptions(
          center: coordinates.ownCoordinate,
          zoom: 18.0,
          plugins: [
            ZoomButtonsPlugin(),
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
          ZoomButtonsPluginOption(
            minZoom: 2,
            maxZoom: 18,
            mini: true,
            padding: 10,
            alignment: Alignment.bottomRight,
          ),
        ],
      ),
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
}
