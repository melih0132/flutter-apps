class Weather {
  final String condition;
  final String description;
  final String icon;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime dateTime;

  Weather({
    required this.condition,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.dateTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];

    return Weather(
      condition: weather['main'] as String,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }
}