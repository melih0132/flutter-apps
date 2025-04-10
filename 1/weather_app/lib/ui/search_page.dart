import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../services/geolocation_service.dart';
import '../services/openweathermap_api.dart';
import 'weather_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    this.lastGeolocationStatus,
    super.key,
  });

  final GeolocationStatus? lastGeolocationStatus;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = ''; // Ce que tape l'utilisateur
  Future<Iterable<Location>>? locationsSearchResults; // Résultats de l'API

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>(); // via Provider
    final mq = MediaQuery.of(context); // taille écran
    final theme = Theme.of(context); // thème pour les styles

    final padding = EdgeInsets.symmetric(
      horizontal: max(mq.size.width * 0.1, 24),
    );

    return Scaffold(
        // Barre d'application
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Recherche'),
        ),
        // Permet de faire défiler la page
        body: SingleChildScrollView(
            child: Column(children: [
          Padding(
            padding: padding,
            // Barre de recherche
            child: TextField(
              onChanged: (value) {
                // Supprime les espaces avant et après
                query = value.trim();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Le setState() permet de redessiner la page lorsque l'on appuie sur le bouton
                setState(() {
                  // Appel API
                  locationsSearchResults =
                      openWeatherMapApi.searchLocations(query);
                });
              },
              child: const Text('Rechercher'),
            ),
          ),

          if (query.isEmpty)
            Text(
              'Saisissez une ville dans la barre de recherche.',
              style: theme.textTheme.bodyMedium!.copyWith(
                fontStyle: FontStyle.italic,
              ),
            )
          else
            // Le FutureBuilder permet d'afficher un widget en fonction de l'état de la requête
            FutureBuilder(
              future: locationsSearchResults,
              // Le snapshot contient les données de la requête
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Affiche un indicateur de chargement pendant la requête
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    'Une erreur est survenue.\n${snapshot.error}',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.error,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                // Si la requête ne renvoie pas de données, on affiche un message
                if (!snapshot.hasData) {
                  return Text(
                    'Aucun résultat pour cette recherche.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                // Si la requête renvoie des données, on les affiche dans une liste
                return Column(
                  children: [
                    // On affiche le nombre de résultats
                    for (final location in snapshot.data!)
                      // On affiche chaque ville dans une liste
                      ListTile(
                        contentPadding: padding,
                        title: Text('${location.name} (${location.country})'),
                        subtitle: Text('${location.lat}, ${location.lon}'),
                        onTap: () {
                          // On utilise le Navigator pour naviguer vers la page de la ville
                          Navigator.push(
                            context,
                            // On utilise le MaterialPageRoute pour naviguer vers la page de la ville
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => WeatherPage(
                                locationName: location.name,
                                latitude: location.lat,
                                longitude: location.lon,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
        ])));
  }
}
