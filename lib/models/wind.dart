class Wind
{
  final double speed;
  final double? deg;
  final double? gust;

  const Wind({required this.speed, this.deg, this.gust});

  factory Wind.fromJson(final Map<String, dynamic> jsonValue)
  {
    return Wind(
      speed: jsonValue['speed'],
      deg: jsonValue['deg'],
      gust: jsonValue['gust'],
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{ 'speed': speed, };
    if (deg != null) {
      jsonValue['deg'] = deg;
    }
    if (gust != null) {
      jsonValue['gust'] = gust;
    }
    return jsonValue;
  }
}
