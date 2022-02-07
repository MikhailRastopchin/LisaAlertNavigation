class Rain
{
  final double oneHour;

  Rain({ required this.oneHour });

  factory Rain.fromJson(final Map<String, dynamic> jsonValue)
    => Rain(oneHour: jsonValue['1h']);

  Map<String, dynamic> toJson() => <String, dynamic>{ '1h': oneHour };
}
