import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../models/weather.dart';

class OpenWeatherMapApi {
  OpenWeatherMapApi({
    required this.apiKey,
    this.units = 'metric',
    this.lang = 'fr',
  });

  static const String baseUrl = 'https://api.openweathermap.org';

  final String apiKey;
  final String units;
  final String lang;

  String getIconUrl(String icon) =>
      'https://openweathermap.org/img/wn/$icon@4x.png';

  Future<Iterable<Location>> searchLocations(
    String query, {
    int limit = 5,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/geo/1.0/direct?appid=$apiKey&q=$query&limit=$limit'),
    );

    if (response.statusCode == HttpStatus.ok) {
      return (jsonDecode(response.body) as List)
          .map((json) => Location.fromJson(json))
          .toList();
    }
    throw Exception('Erreur de recherche (HTTP ${response.statusCode})');
  }

  Future<Weather> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/weather?appid=$apiKey&lat=$lat&lon=$lon&units=$units&lang=$lang',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      return Weather.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur météo (HTTP ${response.statusCode})');
  }

  Future<String> getCityName(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data[0]['name'] as String;
      }
    }
    throw Exception('Impossible de récupérer le nom de la ville');
  }

  Future<List<Weather>> getWeatherForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/forecast?lat=$lat&lon=$lon&units=$units&lang=$lang&appid=$apiKey',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final data = jsonDecode(response.body);
      return (data['list'] as List)
          .map((json) => Weather.fromJson(json))
          .toList();
    }
    throw Exception(
      'Impossible de récupérer les prévisions (HTTP ${response.statusCode})',
    );
  }
}
