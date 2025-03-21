import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'search_page.dart';
import '../services/openweathermap_api.dart';
import '../models/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final String locationName;
  final double latitude;
  final double longitude;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<Weather> _weatherFuture;
  late Future<List<Weather>> _weatherForecastFuture;
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final DateFormat _dateFormatter = DateFormat('EEEE d MMMM', 'fr_FR');

  @override
  void initState() {
    super.initState();
    final api = context.read<OpenWeatherMapApi>();
    _weatherFuture = api.getWeather(widget.latitude, widget.longitude);
    _weatherForecastFuture = api.getWeatherForecast(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Weather>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final weather = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.condition,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.windSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Ressenti : ${weather.feelsLike.toStringAsFixed(1)}°C',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Humidité : ${weather.humidity}%',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              FutureBuilder<List<Weather>>(
                future: _weatherForecastFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final forecasts = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dateFormatter.format(DateTime.now()),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: forecasts.take(5).map((forecast) {
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _timeFormatter.format(forecast.dateTime),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.network(
                                    api.getIconUrl(forecast.icon),
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    forecast.condition,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${forecast.temperature.toStringAsFixed(1)}°C',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${forecast.windSpeed.toStringAsFixed(1)} km/h',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}