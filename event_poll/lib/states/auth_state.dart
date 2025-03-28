import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:event_poll/configs.dart';
import 'package:event_poll/models/user.dart';
import 'package:event_poll/result.dart';

class AuthState extends ChangeNotifier {
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoggedIn => _currentUser != null;

  Future<Result<User, String>> login(String username, String password) async {
    final loginResponse = await http.post(
      Uri.parse('${Configs.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (loginResponse.statusCode == 200) {
      _token = json.decode(loginResponse.body)['token'];

      final userResponse = await http.get(
        Uri.parse('${Configs.baseUrl}/users/me'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (userResponse.statusCode == 200) {
        _currentUser = User.fromJson(json.decode(userResponse.body));
        notifyListeners();
        return Result.success(_currentUser!);
      }
    }

    return Result.failure('Une erreur est survenue');
  }

  Future<Result<Unit, String>> signup(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Configs.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      return response.statusCode == 201
          ? Result.success(unit)
          : Result.failure('Échec de l\'inscription');
    } catch (e) {
      return Result.failure('Erreur réseau');
    }
  }

  Future<Result<User, String>> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${Configs.baseUrl}/users/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        notifyListeners();
        return Result.success(_currentUser!);
      }
      return Result.failure('Échec de récupération du profil');
    } catch (e) {
      return Result.failure('Erreur serveur');
    }
  }

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  String _getLoginError(int statusCode) => statusCode == 401
      ? 'Identifiants invalides'
      : 'Erreur serveur ($statusCode)';
}
