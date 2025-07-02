import 'package:flutter/material.dart';
import '../services/app_blocker_service.dart';

class AppBlockerSettingsDialog extends StatefulWidget {
  const AppBlockerSettingsDialog({super.key});

  @override
  State<AppBlockerSettingsDialog> createState() =>
      _AppBlockerSettingsDialogState();
}


/// État de la boîte de dialogue de gestion des applications bloquées
class _AppBlockerSettingsDialogState extends State<AppBlockerSettingsDialog> {
  // Instance unique du service de blocage d'applications (singleton)
  final AppBlockerService _blocker = AppBlockerService.instance;
  // Contrôleur pour le champ de saisie
  final TextEditingController _controller = TextEditingController();


  /// Ajoute une application à la liste des apps bloquées si non vide et non déjà présente
  void _addApp() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && !_blocker.bannedApps.contains(name)) {
      setState(() {
        _blocker.bannedApps.add(name);
        _controller.clear();
      });
    }
  }


  /// Retire une application de la liste des apps bloquées
  void _removeApp(String name) {
    setState(() {
      _blocker.bannedApps.remove(name);
    });
  }


  /// Construit la boîte de dialogue avec la liste des apps bloquées et le champ d'ajout
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Applications bloquées"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Liste des applications bloquées avec bouton de suppression
          for (var app in _blocker.bannedApps)
            ListTile(
              title: Text(app),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeApp(app),
              ),
            ),
          const Divider(),
          // Champ de saisie pour ajouter une nouvelle application
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Ajouter une application (ex: Discord.exe)',
            ),
            onSubmitted: (_) => _addApp(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fermer"),
        ),
        ElevatedButton(
          onPressed: _addApp,
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}
