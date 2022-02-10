import 'package:latlong2/latlong.dart';


class FoxCoordinate
{
  final int id;
  final String? name;
  final DateTime registeredAt;
  final LatLng coordinate;

  FoxCoordinate({
    required this.id,
    this.name,
    required this.registeredAt,
    required this.coordinate
  });

  factory FoxCoordinate.fromJson(final Map<String, dynamic> jsonValue)
  {
    return FoxCoordinate(
      id: jsonValue['id'],
      name: jsonValue['name'],
      registeredAt: DateTime.parse(jsonValue['registeredAt']),
      coordinate: LatLng.fromJson(jsonValue['coordinate'])
    );
  }

  Map<String, dynamic> toJson()
  {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'registeredAt': registeredAt.toIso8601String(),
      'coordinate': coordinate.toJson(),
    };
  }
}
