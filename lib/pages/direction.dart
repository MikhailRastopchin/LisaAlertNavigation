import 'dart:async';
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve
    );
    _animation = Tween<double>(
        begin: const Angle.degrees(0.0).radians * -1,
        end: const Angle.degrees(180).radians * -1,
      ).animate(_animationController);
    _timer = Timer(const Duration(milliseconds: 25), _updateAzimuth);
  }

  @override
  void dispose()
  {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    final hasPermission = context.watch<CompassService>().hasPermission;
    return Scaffold(
      appBar: AppBar(title: const Text('Направление'), centerTitle: true),
      body: hasPermission ? directionView : _buildPermissionSheet(),
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
        azimuth,
        const SizedBox(height: 10.0),
        SizedBox(
          width: media.size.width,
          height: media.size.width + 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildCompass(points),
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

  Widget get azimuth
  {
    final theme = Theme.of(context);
    final accurency = _currentData?.accuracy?.floor();
    final accurencyText = accurency == null
      ? ''
      : '\u{00b1}$accurency';
    final currentAzimuth = _currentData?.heading == null
      ? ''
      : _currentData!.heading! >= 0
        ? _currentData!.heading!.floor().toString()
        : (180 + (180 + _currentData!.heading!)).floor().toString();
    String info = currentAzimuth.isEmpty
      ? ''
      : accurencyText.isEmpty
        ? '$currentAzimuth\u{00b0}'
        : '$currentAzimuth$accurencyText\u{00b0}';
    return Text('Текущий азимут: $info', style: theme.textTheme.headline5);
  }

  Widget _buildCompass(final Map<Color, List<double>> markers)
  {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return  _buildCompassView(direction, markers);
      },
    );
  }

  Widget _buildCompassView(
    final double direction,
    final Map<Color, List<double>> markers,
  )
  {
    final media = MediaQuery.of(context);
    final content = Container(
      height: media.size.width - 10,
      width: media.size.width - 10,
      padding: const EdgeInsets.all(5.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _buildMarkers(markers),
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
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value,
            child: child
          );
        }
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

  Widget _buildPermissionSheet()
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

  Future<void> _updateAzimuth() async
  {
    _timer.cancel();
    final CompassEvent tmp = await FlutterCompass.events!.first;
    _previosData = _currentData;
    _currentData = tmp;
    _animation = Tween<double>(
      begin: Angle.degrees(_previosData?.heading ?? 0.0).radians * -1,
      end: Angle.degrees(_currentData!.heading!).radians * -1,
    ).animate(_animationController);
    _timer = Timer(Duration.zero, () => _updateAzimuth());
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

  late final AnimationController _animationController;
  late Animation<double> _animation;

  late Timer _timer;
  CompassEvent? _currentData;
  CompassEvent? _previosData;
}
