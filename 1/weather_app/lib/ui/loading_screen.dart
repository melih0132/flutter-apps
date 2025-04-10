import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/services/openweathermap_api.dart';

import '../services/geolocation_service.dart';
import 'search_page.dart';
import 'weather_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    // super.initState() est une méthode qui appelle la méthode initState de la classe parente (State).
    // Cela permet d'exécuter le code de la classe parente avant d'exécuter le code de la classe enfant.
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    // Utilisation de context.read pour accéder à GeolocationService et OpenWeatherMapApi
    final geolocationService = context.read<GeolocationService>();

    // Vérification du statut de la géolocalisation
    final geolocationStatus = await geolocationService.checkStatus();

    if (geolocationStatus == GeolocationStatus.available) {
      // Si la géolocalisation est disponible, on essaie d'obtenir la position actuelle
      final position = await geolocationService.getCurrentPosition();

      if (position != null && mounted) {
        final locationName = await context
            .read<OpenWeatherMapApi>()
            .getLocationName(position.latitude, position.longitude);

        if (mounted) {
          // On utilise Navigator.pushReplacement pour remplacer la page actuelle par WeatherPage
          Navigator.pushReplacement(
            context,
            // On utilise MaterialPageRoute pour créer une nouvelle route vers WeatherPage
            MaterialPageRoute(
              // On passe les paramètres nécessaires à WeatherPage
              builder: (context) => WeatherPage(
                locationName: locationName ?? 'À votre position',
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        }

        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            lastGeolocationStatus: geolocationStatus,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
