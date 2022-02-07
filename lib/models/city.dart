import 'coordinates.dart';


class City
{
  final int id;
  final String name;
  final Coordinates coordinates;

  const City({
    required this.id,
    required this.name,
    required this.coordinates
  });

  factory City.fromJson(final Map<String, dynamic> jsonValue)
  {
    return City(
      id: jsonValue['id'],
      name: jsonValue['name'],
      coordinates: Coordinates.fromJson(jsonValue['coord']),
    );
  }

  Map<String, dynamic> toJson()
    => <String, dynamic>{
      'id': id,
      'name': name,
      'coord': coordinates.toJson(),
    };
}