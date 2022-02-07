class Cloudiness
{
  final int all;

  const Cloudiness(this.all);

  factory Cloudiness.fromJson(final Map<String, dynamic> jsonValue)
    => Cloudiness(jsonValue['all']);

  Map<String, dynamic> toJson() => <String, dynamic>{ 'all': all };
}