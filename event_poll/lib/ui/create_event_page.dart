import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/polls_state.dart';
import '../states/auth_state.dart';
import '../models/poll.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitForm() async {
    final authState = Provider.of<AuthState>(context, listen: false);

    if (!authState.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Accès refusé : seuls les admins peuvent créer un événement")),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    final pollsState = Provider.of<PollsState>(context, listen: false);
    final user = authState.currentUser!;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Création en cours..."),
            ],
          ),
        ),
      );

      final poll = Poll(
        id: 0,
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventDate: _selectedDate!,
        imageName: _fileName,
        user: user,
      );

      debugPrint('Données à envoyer: ${poll.toJson()}');

      await pollsState.createPoll(poll);

      if (pollsState.error != null) {
        throw Exception(pollsState.error);
      }

      if (_selectedFile != null) {
        try {
          final createdPoll = pollsState.polls.firstWhere(
            (p) => p.name == poll.name && p.eventDate == poll.eventDate,
          );

          await pollsState.uploadImage(createdPoll.id, _selectedFile!);
        } catch (e) {
          debugPrint('Erreur upload image: $e');
        }
      }

      // Succès
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Événement créé avec succès")),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      String errorMessage = "Erreur lors de la création";
      String technicalDetails = e.toString();

      if (technicalDetails.contains('400')) {
        errorMessage = "Données rejetées par le serveur (400) - ";

        if (technicalDetails.contains('name')) {
          errorMessage += "Le nom est invalide";
        } else if (technicalDetails.contains('date')) {
          errorMessage += "La date est incorrecte";
        } else if (technicalDetails.contains('user')) {
          errorMessage += "Problème d'utilisateur";
        } else {
          errorMessage += "Format de données incorrect";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Voir les détails",
            onPressed: () => _showErrorDetails(context, e.toString()),
          ),
        ),
      );
    }
  }

  void _showErrorDetails(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Détails de l'erreur"),
        content: SingleChildScrollView(child: Text(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un événement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_selectedDate == null
                    ? "Sélectionner une date"
                    : "Date : ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 10),
              if (_selectedFile != null)
                Column(
                  children: [
                    Image.file(_selectedFile!, height: 150, fit: BoxFit.cover),
                    Text(_fileName ?? "")
                  ],
                ),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text("Choisir une image"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Créer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
