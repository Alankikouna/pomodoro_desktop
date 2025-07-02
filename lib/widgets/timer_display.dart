// Widget d'affichage du temps Pomodoro et boîte de dialogue de réglages
import 'package:flutter/material.dart';
import 'package:pomodoro_desktop/services/timer_service.dart';
import 'package:provider/provider.dart';



/// Affiche le temps restant sous forme de texte (mm:ss)
class TimerDisplay extends StatelessWidget {
  /// Durée à afficher
  final Duration duration;

  const TimerDisplay({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    // Formate les minutes et secondes
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    final isWide = MediaQuery.of(context).size.width > 600;
    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: isWide ? 72 : 48,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 couleur dynamique
      ),
    );
  }
}


/// Boîte de dialogue pour modifier les réglages Pomodoro (durées)
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}


/// État de la boîte de dialogue de réglages Pomodoro
class _SettingsDialogState extends State<SettingsDialog> {
  late int focus;
  late int shortBreak;
  late int longBreak;

  @override
  void initState() {
    super.initState();
    // Récupère les valeurs actuelles depuis le service
    final settings = context.read<TimerService>().settings;
    focus = settings.focusDuration;
    shortBreak = settings.shortBreakDuration;
    longBreak = settings.longBreakDuration;
  }


  @override
  Widget build(BuildContext context) {
    // Boîte de dialogue avec champs pour chaque durée
    return AlertDialog(
      title: const Text("Réglages Pomodoro"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInput("Travail", focus, (v) => focus = int.tryParse(v) ?? focus),
          _buildInput("Pause courte", shortBreak, (v) => shortBreak = int.tryParse(v) ?? shortBreak),
          _buildInput("Pause longue", longBreak, (v) => longBreak = int.tryParse(v) ?? longBreak),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            // Met à jour les réglages dans le service
            final timer = context.read<TimerService>();
            timer.settings.focusDuration = focus;
            timer.settings.shortBreakDuration = shortBreak;
            timer.settings.longBreakDuration = longBreak;
            await timer.settings.save();
            timer.resetTimer(); // appliquer
            Navigator.pop(context);
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }


  /// Champ de saisie pour une durée (travail ou pause)
  Widget _buildInput(String label, int value, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "$label (min)"),
      controller: TextEditingController(text: value.toString()),
      onChanged: onChanged,
    );
  }
}
