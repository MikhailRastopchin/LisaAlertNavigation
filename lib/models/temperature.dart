class Temperature
{
  final double day;
  final double? min;
  final double? max;
  final double night;
  final double evening;
  final double morning;

  Temperature({
    required this.day,
    this.min,
    this.max,
    required this.night,
    required this.evening,
    required this.morning,
  });

  factory Temperature.fromJson(final Map<String, dynamic> jsonValue)
  {
    double? min;
    final jsonMin = jsonValue['min'];
    if (jsonMin != null) {
      min = (jsonMin as num). toDouble();
    }
    double? max;
    final jsonMax = jsonValue['max'];
    if (jsonMax != null) {
      max = (jsonMax as num). toDouble();
    }
    return Temperature(
      day: (jsonValue['day'] as num). toDouble(),
      min: min,
      max: max,
      night: (jsonValue['night'] as num). toDouble(),
      evening: (jsonValue['eve'] as num). toDouble(),
      morning: (jsonValue['morn'] as num). toDouble(),
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue =  <String, dynamic>{
      'day': day,
      'night': night,
      'eve': evening,
      'morn': morning,
    };
    if (min != null) {
      jsonValue['min'] = min;
    }
    if (max != null) {
      jsonValue['max'] = max;
    }
    return jsonValue;
  }
}