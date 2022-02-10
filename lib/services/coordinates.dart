import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../utils/file_system.dart';
import '../models.dart';


final _log = Logger('CooordinatesService');


const _kRefreshRangeExpiration = Duration(seconds: 5);


class CoordinatesService
  with ChangeNotifier
{
  LatLng? get ownCoordinate => _ownCoordinate;

  List<AnotherFoxTrack> get tracks => _tracks;

  bool get autoUpdating => _autoUpdating;

  set autoUpdating(final bool value)
  {
    if (_autoUpdating == value) return;
    _autoUpdating = value;
    if (_autoUpdating) {
      _startUpdating();
    } else {
      _updateTracksTimer?.cancel();
    }
  }

  Future<void> init() async
  {
    final now = DateTime.now();
    const locale = Locale('ru', 'RU');
    final localeName = Intl.canonicalizedLocale(locale.toString());
    final formatter = DateFormat.yMd(localeName).add_Hm();
    final path = formatter.format(now);
    _storagePath = await getFilesPath(path: path, create: true);
    await _updateOwnCoordinate();
    _ownCoordinateTimer = Timer.periodic(
      _kRefreshRangeExpiration,
      (_ownCoordinateTimer) => _updateOwnCoordinate(),
    );
  }

  Future<void> _updateTracks() async
  {
    _updateTracksTimer?.cancel();
    final coordinates = await _getCoordinates();
    final updatedTracks = _tracks.toList();
    for (var coordinate in coordinates) {
      if (!updatedTracks.any((track) => track.id == coordinate.id)) {
        updatedTracks.add(AnotherFoxTrack(
          id: coordinate.id,
          name: coordinate.name ?? '',
          currentCoordinate: coordinate.coordinate,
          track: { DateTime.now(): coordinate.coordinate},
        ));
      } else {
        final index = updatedTracks.indexWhere((track) => track.id == coordinate.id);
        final updatedTrack = updatedTracks[index].copyWith(
          currentCoordinate: coordinate.coordinate
        );
        updatedTrack.track[DateTime.now()] = coordinate.coordinate;
        updatedTracks[index] = updatedTrack;
      }
    }
    _tracks = updatedTracks;
    await _saveTracks();
    if (autoUpdating) _startUpdating();
    notifyListeners();
  }

  Future<List<FoxCoordinate>> _getCoordinates() async
  {
    final random = Random();
    final coodinates = [
      FoxCoordinate(
        id: 01,
        name: 'Вася',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 02,
        name: 'Коля',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 03,
        name: 'Роберт Аркадиевич',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 04,
        name: 'Петя',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 05,
        name: 'Вова',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 06,
        name: 'Ашот',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 07,
        name: 'Абдукохор',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 08,
        name: 'Файзула',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 09,
        name: 'Гурбангулы Бердымухамедов',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 10,
        name: 'Осенезатор',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 11,
        name: 'ХЗ кто',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9858 + random.nextDouble() / 3000,
        ),
      ),
    ];
    return coodinates;
  }

  Future<void> _updateOwnCoordinate() async
  {
    final random = Random();
    final newCoordinate = LatLng(
      56.9958 + random.nextDouble() / 500,
      40.9858 + random.nextDouble() / 500,
    );
    _ownCoordinate = newCoordinate;
    notifyListeners();
  }

  @override
  void dispose()
  {
    autoUpdating = false;
    _ownCoordinateTimer.cancel();
    super.dispose();
  }

  void _startUpdating()
  {
    _updateTracksTimer = Timer(_kRefreshRangeExpiration, () async {
      try {
        await _updateTracks();
      } catch (e) {
        _log.warning('Failed to update tracks: $e');
      }
    });
  }

  Future<void> _saveTracks() async
  {
    for (var track in _tracks) {
      final path = '$_storagePath/${track.id}_${track.name}.json';
      await saveJson(path, _tracks);
    }
    _log.info('Tracks saved in the local storage.');
  }

  late final String _storagePath;
  late final Timer _ownCoordinateTimer;

  List<AnotherFoxTrack> _tracks = [];
  Timer? _updateTracksTimer;
  bool _autoUpdating = false;
  LatLng? _ownCoordinate;
}
