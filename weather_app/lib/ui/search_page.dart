import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/openweathermap_api.dart';
import '../models/location.dart';
import 'weather_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  Future<Iterable<Location>>? locationsSearchResults;

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column( 
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Entrez une ville',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (query.isNotEmpty) {
                setState(() {
                  locationsSearchResults = openWeatherMapApi.searchLocations(
                    query,
                  );
                });
              }
            },
            child: const Text('Rechercher'),
          ),
          if (query.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Saisissez une ville dans la barre de recherche.'),
            )
          else
            Expanded(
              child: FutureBuilder<Iterable<Location>>(
                future: locationsSearchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Une erreur est survenue.\n${snapshot.error}',
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Aucun résultat pour cette recherche.'),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!
                            .map(
                              (location) => ListTile(
                                title: Text(location.name),
                                subtitle: Text(location.country),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => WeatherPage(
                                            locationName:
                                                '${location.name}, ${location.country}',
                                            latitude: location.lat,
                                            longitude: location.lon,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
