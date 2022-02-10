import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:la_navigation/services/coordinates.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';


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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FlutterMap(
          options: MapOptions(
            center: coordinates.ownCoordinate,
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              tileProvider: const FileTileProvider()
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(56.99, 40.57),
                  builder: (ctx) =>
                  const Icon(Icons.location_on, color: Colors.red, size: 40.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
