import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/auth_state.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    this.title,
    this.body,
    super.key,
  });

  final String? title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Event Poll'),
        centerTitle: true,
        actions: [
          if (authState.isLoggedIn)
            Text(authState.currentUser?.username ?? 'Invité'),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(authState.isLoggedIn
                  ? 'Connecté en tant que ${authState.currentUser?.username}'
                  : 'Connectez-vous pour vous inscrire à un événement !'),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Événements'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/polls', (_) => false);
              },
            ),
            if (!authState.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Connexion'),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
              ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Inscription'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/signup', (_) => false);
              },
            ),
            if (authState.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () {
                  authState.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/polls', (_) => false);
                },
              ),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: body,
      ),
    );
  }
}
