import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_poll/states/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String confirmPassword = '';
  String? error;

  String? _validatePasswordMatch(String? value) {
    return value != password ? 'Les mots de passe ne correspondent pas' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await context.read<AuthState>().signup(username, password);

    result.when(
      success: (_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      failure: (errorMsg) {
        setState(() => error = errorMsg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Nom d\'utilisateur'),
              onChanged: (value) => username = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              onChanged: (value) => password = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Confirmer le mot de passe'),
              obscureText: true,
              validator: _validatePasswordMatch,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
