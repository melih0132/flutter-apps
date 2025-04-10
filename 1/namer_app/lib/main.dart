import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

/// Composant racine de l'application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Mise à disposition de la classe d'état à tout les composants enfant.
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // Interface principale de l'application.
        home: const MyHomePage(),
      ),
    );
  }
}

/// Classe d'état principale de l'application.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  late List<WordPair> favorites;
  var initialized = false;

  late SharedPreferencesWithCache _storage;

  Future<void> init() async {
    if (initialized) {
      return;
    }

    _storage = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    final data = _storage.getString('favorites');
    if (data == null) {
      favorites = <WordPair>[];
    } else {
      favorites = _wordPairsFromJson(data);
    }

    initialized = true;
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    _saveToStorage();
    notifyListeners();
  }

  void deleteFavorite(WordPair favorite) {
    favorites.remove(favorite);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    await _storage.setString('favorites', _wordPairsToJson(favorites));
  }

  static String _wordPairsToJson(List<WordPair> data) {
    return json.encode(
      data
          .map((pair) => <String, dynamic>{
                'first': pair.first,
                'second': pair.second,
              })
          .toList(),
    );
  }

  static List<WordPair> _wordPairsFromJson(String data) {
    return List<WordPair>.from(
      (json.decode(data) as List).map(
        (item) => WordPair(item['first'], item['second']),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  Future<void>? initializer;

  @override
  void initState() {
    super.initState();
    // Récupération de `AppState` (sans surveiller les modifications d'état).
    var appState = context.read<MyAppState>();
    // Déclenche l'initialisation et stock la référence de la tâche dans `initializer`.
    initializer = appState.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Surveille l'avancement de la tâche `initializer`.
      future: initializer,
      builder: (context, snapshot) {
        // Si la tâche n'est pas complète :
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Widget page;

        switch (selectedIndex) {
          case 0:
            page = const GeneratorPage();
            break;
          case 1:
            page = const FavoritesPage();
            break;
          default:
            throw UnimplementedError('aucun composant pour $selectedIndex');
        }

        var body = Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Accueil',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favoris',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
                body: body,
              );
            } else {
              return Scaffold(
                body: Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Accueil'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favoris'),
                          ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(child: body),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération de `AppState` en surveillant les mises à jour d'état.
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text("J'aime"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Suivant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération de `AppState` en surveillant les mises à jour d'état.
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          "Aucun favoris pour le moment",
          style: theme.textTheme.bodyMedium!.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Vous avez ${appState.favorites.length} favoris :",
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
        // S'assure que `ListView` ne rentre pas en conflit avec `Column`
        // et occupe tout l'espace disponible.
        Expanded(
          child: ListView(
            children: [
              for (var fav in appState.favorites)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          appState.deleteFavorite(fav);
                        },
                      ),
                      title: Text(
                        fav.asLowerCase,
                        semanticsLabel: fav.asPascalCase,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
