import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/poll.dart';
import '../models/user.dart';
import '../models/vote.dart';
import '../configs.dart';

class PollsState with ChangeNotifier {
  String? _token;
  List<Poll> _polls = [];
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  List<Poll> get polls => _polls;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  void setAuthToken(String? token) {
    _token = token;
    _polls = [];
    fetchPolls();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Configs.baseUrl}/users/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      _error = "Erreur récupération utilisateur : $e";
    }
  }

  Future<void> fetchPolls() async {
    if (_token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Configs.baseUrl}/polls'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _polls = data.map((json) => Poll.fromJson(json)).toList();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _error = "Erreur réseau : $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPoll(Poll poll) async {
    if (_token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pollJson = poll.toJson();
      debugPrint('Envoi au serveur: ${json.encode(pollJson)}');

      final response = await http.post(
        Uri.parse('${Configs.baseUrl}/polls'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode(pollJson),
      );

      debugPrint('Réponse du serveur: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201) {
        await fetchPolls();
      } else {
        _handleErrorResponse(response);
        debugPrint('Erreur détaillée: ${response.body}');
      }
    } catch (e) {
      _error = "Erreur création : $e";
      debugPrint('Erreur complète: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updatePoll(Poll poll) async {
    if (_token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${Configs.baseUrl}/polls/${poll.id}'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode(poll.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchPolls();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _error = "Erreur modification : $e";
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> deletePoll(String pollId) async {
    if (_token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${Configs.baseUrl}/polls/$pollId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        await fetchPolls();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _error = "Erreur suppression : $e";
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> uploadImage(int pollId, File imageFile) async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Configs.baseUrl}/polls/$pollId/image'),
      );

      request.headers['Authorization'] = 'Bearer $_token';
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        await fetchPolls(); // Rafraîchir les données
      } else {
        _error = "Erreur upload image : ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau image : $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(String pollId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${Configs.baseUrl}/polls/$pollId/image'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 204) {
        await fetchPolls();
      } else {
        _error = "Erreur suppression image : ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau image : $e";
    }
  }

  Future<List<Vote>> getVotes(String pollId) async {
    if (_token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${Configs.baseUrl}/polls/$pollId/votes'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.map<Vote>((v) => Vote.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      _error = "Erreur récupération votes : $e";
      return [];
    }
  }

  Future<void> addVote(String pollId, Map<String, dynamic> voteData) async {
    if (_token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${Configs.baseUrl}/polls/$pollId/votes'),
        headers: {'Authorization': 'Bearer $_token'},
        body: json.encode(voteData),
      );

      if (response.statusCode != 201) {
        _error = "Erreur vote : ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau vote : $e";
    }
  }

  Future<void> deleteVote(String pollId, String voteId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${Configs.baseUrl}/polls/$pollId/votes/$voteId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode != 204) {
        _error = "Erreur suppression vote : ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau vote : $e";
    }
  }

  void _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 400 && statusCode < 500) {
      _error = "Erreur client : $statusCode";
    } else if (statusCode >= 500) {
      _error = "Erreur serveur : $statusCode";
    } else {
      _error = "Erreur inconnue : $statusCode";
    }
  }
}
