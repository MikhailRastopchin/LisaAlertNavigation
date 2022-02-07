class Condition
{
  final int id;
  final String main;
  final String? description;
  final String? icon;

  Condition({required this.id, required this.main, this.description, this.icon});

  factory Condition.fromJson(final Map<String, dynamic> jsonValue)
  {
    return Condition(
      id: jsonValue['id'],
      main: jsonValue['main'],
      description: jsonValue['description'],
      icon: jsonValue['icon']
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{
      'id': id,
      'main': main,
    };
    if (description != null) {
      jsonValue['description'] = description;
    }
    if (icon != null) {
      jsonValue['icon'] = icon;
    }
    return jsonValue;
  }
}