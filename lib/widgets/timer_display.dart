import 'package:flutter/material.dart';
import 'package:pomodoro_desktop/services/timer_service.dart';
import 'package:provider/provider.dart';


class TimerDisplay extends StatelessWidget {
  final Duration duration;

  const TimerDisplay({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int focus;
  late int shortBreak;
  late int longBreak;

  @override
  void initState() {
    super.initState();
    final settings = context.read<TimerService>().settings;
    focus = settings.focusDuration;
    shortBreak = settings.shortBreakDuration;
    longBreak = settings.longBreakDuration;
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _buildInput(String label, int value, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "$label (min)"),
      controller: TextEditingController(text: value.toString()),
      onChanged: onChanged,
    );
  }
}
