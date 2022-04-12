import 'dart:math' as math;

import 'package:angles/angles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:la_navigation/services/storage/compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/storage/coordinates.dart';
import '../utils/scale_converter.dart';
import 'common/styles.dart';


class DirectionPage extends StatefulWidget
{
  const DirectionPage({ final Key? key}) : super(key: key);

  @override
  State<DirectionPage> createState() => _DirectionPageState();
}


class _DirectionPageState extends State<DirectionPage>
  with TickerProviderStateMixin
{
  @override
  Widget build(final BuildContext context)
  {
    final hasPermission = context.watch<CompassService>().hasPermission;
    return Scaffold(
      appBar: AppBar(title: const Text('Направление'), centerTitle: true),
      body: hasPermission ? directionView : const _PermissionSheet(),
    );
  }

  Widget get directionView
  {
    final media = MediaQuery.of(context);
    final coordinatesService = context.watch<CoordinatesService>();
    final ownCoordinate = coordinatesService.ownCoordinate!;
    final tracks = coordinatesService.tracks;
    final points = _getAzimuthsAndDistances(ownCoordinate, tracks);
    final pointsList = points.entries.toList();
    return Column(
      children: <Widget>[
        const SizedBox(height: 10.0),
        SizedBox(
          width: media.size.width,
          height: media.size.width + 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _CompassView(markers:points),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final point =  pointsList[index];
              return _buildLegendEntry(
                color: point.key,
                name: tracks[index].name,
                distance: point.value[1],
              );
            },
            itemCount: pointsList.length,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendEntry({
    required final Color color,
    required final double distance,
    required final String name,
  })
  {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.navigation, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: TextStyle(color: color))),
            const SizedBox(width: 10),
            Text('${distance.round()} м.', style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Map<Color, List<double>> _getAzimuthsAndDistances(
    final LatLng ownCoordinate,
    final List<AnotherFoxTrack> coordinates,
  )
  {
    final azimuthsAndDistances = <Color, List<double>>{};
    for (var index = 0; index < coordinates.length; index++) {
      final targetTrack = coordinates[index];
      final targetCoordinate = targetTrack.currentCoordinate;
      final angleAndDistance = calculeteAzimuthAndDistance(
        ownCoordinate,
        targetCoordinate,
      );
      final dividedIndex = index > 9 ? index % 10 : index;
      assert(dividedIndex < kMarkerColors.length);
      final color = kMarkerColors[dividedIndex];
      azimuthsAndDistances[color] = angleAndDistance;
    }
    return azimuthsAndDistances;
  }
}


class _CompassView extends StatefulWidget
{
  final Map<Color, List<double>> markers;

  const _CompassView({ final Key? key, required this.markers}) : super(key: key);

  @override
  State<_CompassView> createState() => _CompassViewState();
}


class _CompassViewState extends State<_CompassView>
{
  @override
  void initState()
  {
    super.initState();
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() {
          _previosDirection = _currentDirection ?? 0;
          _currentDirection = event.heading;
          _accuracy = event.accuracy;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context)
  {
    final media = MediaQuery.of(context);
    final content = Transform.rotate(
      angle: Angle.degrees(_currentDirection ?? _previosDirection).radians * - 1,
      child: Container(
        height: media.size.width - 10,
        width: media.size.width - 10,
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _buildMarkers(widget.markers),
            Padding(
              padding: const EdgeInsets.all(36.0),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(
                    color: AppStyle.liteColors.primaryColor,
                    width: 3.0,
                  )),
                ),
                child: Image.asset('assets/images/compass.png')),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10.0),
        directionInfo,
        Container(
          alignment: Alignment.bottomCenter,
          child: Transform.rotate(
            child: const Icon(Icons.navigation, size: 40.0),
            angle: math.pi,
          ),
        ),
        Material(
          shape: const CircleBorder(),
          color: AppStyle.liteColors.cardColor,
          clipBehavior: Clip.antiAlias,
          elevation: 10.0,
          child: content,
        ),
      ],
    );
  }

  Widget get directionInfo
  {
    final theme = Theme.of(context);
    final accuracyText = _accuracy == null
      ? ''
      : '\u{00b1}${_accuracy!.floor()};';
    final currentAzimuth = _currentDirection == null
      ? ''
      : _currentDirection! >= 0
        ? _currentDirection!.floor().toString()
        : (180 + (180 + _currentDirection!)).floor().toString();
    String info = currentAzimuth.isEmpty
      ? ''
      : accuracyText.isEmpty
        ? '$currentAzimuth\u{00b0}'
        : '$currentAzimuth$accuracyText\u{00b0}';
    return Text('Текущий азимут: $info',
      style: theme.textTheme.headline5,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMarkers(final Map<Color, List<double>> info)
  {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: info.entries
            .map(
              (azimuth) => Transform.rotate(
                angle: Angle.degrees(azimuth.value[0]).radians,
                child: Container(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  alignment: Alignment.topCenter,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(Icons.navigation, color: azimuth.key, size: 40.0),
                ),
              )
            )
            .toList(),
        );
      }
    );
  }

  double? _currentDirection;
  double? _accuracy;
  double _previosDirection = 0;
}


class _PermissionSheet extends StatelessWidget
{
  const _PermissionSheet({Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context)
  {
    final compassService = context.read<CompassService>();
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Для работы необходимо разрешение использования компаса',
            style: theme.textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const Text('Запросить разрешение'),
            onPressed: () => compassService.requestPermission(),
          ),
        ],
      ),
    );
  }
}
