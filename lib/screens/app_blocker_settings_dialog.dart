import 'package:flutter/material.dart';
import '../services/app_blocker_service.dart';

class AppBlockerSettingsDialog extends StatefulWidget {
  const AppBlockerSettingsDialog({super.key});

  @override
  State<AppBlockerSettingsDialog> createState() =>
      _AppBlockerSettingsDialogState();
}

class _AppBlockerSettingsDialogState extends State<AppBlockerSettingsDialog> {
  final AppBlockerService _blocker = AppBlockerService.instance;
  final TextEditingController _controller = TextEditingController();

  void _addApp() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && !_blocker.bannedApps.contains(name)) {
      setState(() {
        _blocker.bannedApps.add(name);
        _controller.clear();
      });
    }
  }

  void _removeApp(String name) {
    setState(() {
      _blocker.bannedApps.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Applications bloquées"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var app in _blocker.bannedApps)
            ListTile(
              title: Text(app),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeApp(app),
              ),
            ),
          const Divider(),
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
