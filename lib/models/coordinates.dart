class Coordinates
{
  final double latitude;
  final double longitude;

  const Coordinates({ required this.latitude, required this.longitude });

  factory Coordinates.fromJson(final Map<String, dynamic> jsonValue)
  {
    return Coordinates(
      latitude: jsonValue['lat'],
      longitude: jsonValue['lon'],
    );
  }

  Map<String, dynamic> toJson()
    => <String, dynamic>{ 'lat': latitude, 'lon': longitude };
}