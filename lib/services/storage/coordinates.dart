import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

import '../../utils/file_system.dart';
import '../../models.dart';


final _log = Logger('CooordinatesService');


const _kRefreshRangeExpiration = Duration(seconds: 5);


class CoordinatesService
  with ChangeNotifier
{
  LatLng? get ownCoordinate => _ownCoordinate;

  LatLng? get oldOwnCoordinate => _oldOwnCoordinate;

  List<AnotherFoxTrack> get tracks => _tracks;

  bool get autoUpdatingTracks => _autoUpdatingTracks;

  set autoUpdatingTracks(final bool value)
  {
    if (_autoUpdatingTracks == value) return;
    _autoUpdatingTracks = value;
    if (_autoUpdatingTracks) {
      _startUpdatingTracks();
    } else {
      _updateTracksTimer?.cancel();
    }
  }

  bool get showOwnTrack => _showOwnTack;

  set showOwnTrack(final bool value)
  {
    if (_showOwnTack == value) return;
    _showOwnTack = value;
    notifyListeners();
  }

  AnotherFoxTrack get ownTrack => _ownTrack;

  bool get isLocationServiceEnabled => _isLocationServiceEnabled;

  Future<void> setLocationServiceEnabled(final bool value) async
  {
    if (_isLocationServiceEnabled == value) return;
    _isLocationServiceEnabled = value;
    if (_isLocationServiceEnabled) {
      await _updateOwnCoordinate();
      _ownCoordinateTimer = Timer.periodic(
        _kRefreshRangeExpiration,
        (_ownCoordinateTimer) => _updateOwnCoordinate(),
      );
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
    _location = Location();
    _isLocationServiceEnabled = await _location.serviceEnabled();
    if (!_isLocationServiceEnabled) {
      _isLocationServiceEnabled = await _location.requestService();
    }
    if (!_isLocationServiceEnabled) {
      return;
    } else {
      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
      }
      if (_permissionGranted != PermissionStatus.granted) return;
      await _updateOwnCoordinate();
      _ownTrack = AnotherFoxTrack(
        id: 0,
        name: 'own',
        currentCoordinate: _ownCoordinate!,
        track: {DateTime.now(): _ownCoordinate!}
      );
      _ownCoordinateTimer = Timer.periodic(
        _kRefreshRangeExpiration,
        (_ownCoordinateTimer) => _updateOwnCoordinate(),
      );
    }
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
    if (autoUpdatingTracks) _startUpdatingTracks();
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
          56.9999 + random.nextDouble() / 3000,
          40.9899 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 03,
        name: 'Роберт Аркадиевич',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.0184 + random.nextDouble() / 3000,
          92.8671 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 02,
        name: 'Коля',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9940 + random.nextDouble() / 3000,
          41.0000 + random.nextDouble() / 3000,
        ),
      ),
      FoxCoordinate(
        id: 04,
        name: 'Петя',
        registeredAt: DateTime.now(),
        coordinate: LatLng(
          56.9958 + random.nextDouble() / 3000,
          40.9500 + random.nextDouble() / 3000,
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
      ),/*
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
      ),*/
    ];
    return coodinates;
  }

  Future<void> _updateOwnCoordinate() async
  {
    try {
      final currentLocation = await _location.getLocation();
      _oldOwnCoordinate = _ownCoordinate;
      _ownCoordinate = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!
      );
      _ownTrack.track[DateTime.now()] = _ownCoordinate!;
      notifyListeners();
    } catch (e) {
      _log.warning('Failed to update own coordinate: $e');
    }
  }

  @override
  void dispose()
  {
    autoUpdatingTracks = false;
    _ownCoordinateTimer.cancel();
    super.dispose();
  }

  void _startUpdatingTracks()
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
    final tracks =_tracks.toList();
    tracks.add(_ownTrack);
    for (var track in tracks) {
      final path = '$_storagePath/${track.id}_${track.name}.json';
      await saveJson(path, _tracks);
    }
    _log.info('Tracks saved in the local storage.');
  }

  late final String _storagePath;
  late final Timer _ownCoordinateTimer;
  late final Location _location;
  late final AnotherFoxTrack _ownTrack;

  late bool _isLocationServiceEnabled;
  late PermissionStatus _permissionGranted;
  List<AnotherFoxTrack> _tracks = [];
  Timer? _updateTracksTimer;
  bool _autoUpdatingTracks = false;
  LatLng? _ownCoordinate;
  LatLng? _oldOwnCoordinate;
  bool _showOwnTack = false;
}
