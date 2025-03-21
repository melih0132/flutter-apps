import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/geolocation_service.dart';
import '../services/openweathermap_api.dart';
import 'weather_page.dart';
import 'search_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<void> getLocationData() async {
    final geolocationService = context.read<GeolocationService>();
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    final position = await geolocationService.getCurrentPosition();

    if (mounted) {
      if (position != null) {
        try {
          final cityName = await openWeatherMapApi.getCityName(
            position.latitude,
            position.longitude,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => WeatherPage(
                    locationName: cityName,
                    latitude: position.latitude,
                    longitude: position.longitude,
                  ),
            ),
          );
        } catch (e) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
