import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/poll.dart';
import 'ui/app_scaffold.dart';
import 'states/auth_state.dart';
import 'states/polls_state.dart';
import 'ui/event_list_page.dart';
import 'ui/event_detail_page.dart';
import 'ui/login_page.dart';
import 'ui/signup_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState(),
        ),
        ChangeNotifierProxyProvider<AuthState, PollsState>(
          create: (_) => PollsState(),
          update: (_, authState, pollsState) =>
              pollsState!..setAuthToken(authState.token),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Poll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      supportedLocales: const [Locale('fr')],
      locale: const Locale('fr'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: '/polls',
      routes: {
        '/polls': (context) => const AppScaffold(
              title: 'Événements',
              body: EventList(),
            ),
        '/polls/create': (context) => const AppScaffold(
              title: 'Ajouter un événement',
              body: Placeholder(child: Center(child: Text('POLLS_CREATE'))),
            ),
        '/polls/detail': (context) => AppScaffold(
              title: 'Détails de l\'événement',
              body: EventDetail(
                  poll: ModalRoute.of(context)!.settings.arguments as Poll),
            ),
        '/polls/update': (context) => const AppScaffold(
              title: 'Modifier un événement',
              body: Placeholder(child: Center(child: Text('POLLS_UPDATE'))),
            ),
        '/login': (context) => const AppScaffold(
              title: 'Connexion',
              body: LoginPage(),
            ),
        '/signup': (context) => const AppScaffold(
              title: 'Inscription',
              body: SignupPage(),
            ),
      },
    );
  }
}
