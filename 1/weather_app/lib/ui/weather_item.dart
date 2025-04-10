import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/openweathermap_api.dart';

final _dateFormatter = DateFormat.MMMMEEEEd();
final _hourFormatter = DateFormat.Hm();

// Cette fonction formate la température à une décimale près et ajoute "°C" à la fin.
String _formatTemp(double value) => '${((value * 10).round() / 10)}°C';

// Cette fonction formate la vitesse du vent à l'entier près et ajoute "km/h" à la fin.
String _formatSpeed(double value) => '${value.round()} km/h';

// Cette fonction met la première lettre d'une chaîne de caractères en majuscule et le reste en minuscule.
String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);

class WeatherBlock extends StatelessWidget {
  const WeatherBlock(this.weather, {super.key});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // On utilise un Card pour afficher les informations météo de manière stylisée.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // On affiche l'icône météo.
                Image.network(
                  context.read<OpenWeatherMapApi>().getIconUrl(
                        weather.icon,
                        OpenWeatherMapIconSize.large,
                      ),
                ),

                Column(
                  children: [
                    Text(
                      _capitalize(weather.description),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTemp(weather.temperature),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatSpeed(weather.windSpeed),
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTemp(weather.temperatureMin),
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.blue.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|'),
                ),
                Text(
                  _formatTemp(weather.temperatureMax),
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherTile extends StatelessWidget {
  const WeatherTile(this.weather, {super.key});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        // On utilise un ConstrainedBox pour limiter la largeur de l'élément.
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 128,
            maxWidth: 160,
          ),
          child: Column(
            children: [
              Text(_dateFormatter.format(weather.dateTime)),
              Text(_hourFormatter.format(weather.dateTime)),
              const Spacer(flex: 1),
              Image.network(
                context.read<OpenWeatherMapApi>().getIconUrl(
                      weather.icon,
                      OpenWeatherMapIconSize.medium,
                    ),
              ),
              Text(
                _capitalize(weather.description),
                textAlign: TextAlign.center,
              ),
              // Spacer pour espacer l'icône de la température.
              const Spacer(flex: 1),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTemp(weather.temperatureMin),
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|'),
                  ),
                  Text(
                    _formatSpeed(weather.windSpeed),
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
