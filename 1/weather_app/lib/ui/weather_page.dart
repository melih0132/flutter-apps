import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/ui/weather_item.dart';

import '../services/openweathermap_api.dart';
import 'search_page.dart';

// Ce StatefulWidget affiche la météo actuelle et la météo sur 5 jours pour un emplacement donné.
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
  // Le ScrollController est utilisé pour contrôler le défilement horizontal de la liste des prévisions météo sur 5 jours.
  final _horizontalScrollController = ScrollController();

  FutureBuilder weatherFutureBuilder<T>({
    // Le FutureBuilder est un widget qui construit son contenu en fonction de l'état d'un Future.
    // Un Future étant une opération asynchrone qui peut se terminer avec succès ou échouer.
    required Future<T> future,
    // ValueWidgetBuilder est une fonction qui construit un widget en fonction de l'état du Future.
    required ValueWidgetBuilder<T> builder,
  }) {
    // Le FutureBuilder est utilisé pour construire le widget en fonction de l'état du Future.
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final theme = Theme.of(context);

        if (snapshot.hasError) {
          return Text(
            'Une erreur est survenue.\n${snapshot.error?.toString()}',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.error,
              fontStyle: FontStyle.italic,
            ),
          );
        }

        if (!snapshot.hasData) {
          return Text(
            'Aucune donnée disponible à cet emplacement.',
            style: theme.textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
            ),
          );
        }

        return builder(context, snapshot.data!, null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Météo à ${widget.locationName}'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Rechercher'),
          ),
        ],
      ),
      body: Container(
        // EdgeInsets est utilisé pour ajouter des marges autour du widget.
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Column(
          children: [
            weatherFutureBuilder(
              future: openWeatherMapApi.getWeather(
                widget.latitude,
                widget.longitude,
              ),
              builder: (context, data, _) {
                return WeatherBlock(data);
              },
            ),
            // SizedBox est utilisé pour ajouter un espacement entre les widgets.
            const SizedBox(height: 16),
            weatherFutureBuilder(
              future: openWeatherMapApi.get5DaysWeather(
                widget.latitude,
                widget.longitude,
              ),
              builder: (context, data, _) {
                // CustomScrollbarWithSingleChildScrollView est un widget personnalisé qui ajoute une barre de défilement personnalisée à un SingleChildScrollView.
                // Un SingleChildScrollView est un widget qui permet de faire défiler son contenu lorsqu'il dépasse la taille de l'écran.
                // Le ScrollController est utilisé pour contrôler le défilement horizontal de la liste des prévisions météo sur 5 jours.
                return CustomScrollbarWithSingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        for (var weather in data) WeatherTile(weather),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Un StatefulWidget est un widget qui peut changer d'état au cours de son cycle de vie.
class CustomScrollbarWithSingleChildScrollView extends StatelessWidget {
  const CustomScrollbarWithSingleChildScrollView({
    required this.controller,
    required this.child,
    required this.scrollDirection,
    super.key,
  });

  // Le ScrollController est utilisé pour contrôler le défilement du SingleChildScrollView.
  final ScrollController controller;
  // Le widget enfant est le contenu du SingleChildScrollView.
  // Il peut s'agir de n'importe quel widget, y compris un Row, un Column, un ListView, etc.
  final Widget child;
  // Le Axis est une énumération qui représente la direction du défilement.
  // Il peut être horizontal ou vertical.
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // CustomScrollBehavior est une classe qui permet de personnaliser le comportement de défilement.
      // Elle est utilisée pour définir les appareils qui peuvent faire défiler le widget.
      behavior: const CustomScrollBehavior(),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: child,
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
