import 'package:latlong2/latlong.dart';


class AnotherFoxTrack
{
  final int id;
  final String name;
  final Map<DateTime, LatLng> track;
  final LatLng currentCoordinate;

  AnotherFoxTrack({
    required this.id,
    required this.name,
    this.track = const {},
    required this.currentCoordinate
  });

  factory AnotherFoxTrack.fromJson(final Map<String, dynamic> jsonvalue)
  {
    final jsonTrack = jsonvalue['track'] as Map<String, dynamic>;
    final track = jsonTrack.map((key, value) => MapEntry(
      DateTime.parse(key),
      LatLng.fromJson(value)
    ));
    return AnotherFoxTrack(
      id: jsonvalue['id'],
      name: jsonvalue['name'],
      currentCoordinate: LatLng.fromJson(jsonvalue['current']),
      track: track
    );
  }

  Map<String, dynamic> toJson()
  {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'current': currentCoordinate.toJson(),
      'track': track.map((key, value) => MapEntry(
        key.toIso8601String(),
        value.toJson()
      )),
    };
  }

  AnotherFoxTrack copyWith({
    final int? id,
    final String? name,
    final Map<DateTime, LatLng>? track,
    final LatLng? currentCoordinate,
  })
  {
    return AnotherFoxTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      track: track ?? this.track,
      currentCoordinate: currentCoordinate ?? this.currentCoordinate,
    );
  }
}