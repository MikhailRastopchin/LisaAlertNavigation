class Snow
{
  final double oneHour;

  Snow({ required this.oneHour });

  factory Snow.fromJson(final Map<String, dynamic> jsonValue)
    => Snow(oneHour: jsonValue['1h']);

  Map<String, dynamic> toJson() => <String, dynamic>{ '1h': oneHour };
}
