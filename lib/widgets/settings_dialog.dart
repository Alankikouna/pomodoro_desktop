import 'package:flutter/material.dart';
import 'package:pomodoro_desktop/models/pomodoro_settings.dart';
import 'package:pomodoro_desktop/services/timer_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Affiche une boîte de dialogue pour modifier les paramètres Pomodoro
Future<void> showSettingsDialog(BuildContext context, PomodoroSettings settings, TimerService timer) async {
  final focusCtrl = TextEditingController(text: settings.focusDuration.toString());
  final shortCtrl = TextEditingController(text: settings.shortBreakDuration.toString());
  final longCtrl = TextEditingController(text: settings.longBreakDuration.toString());

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Modifier les durées (minutes)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: focusCtrl,
              decoration: const InputDecoration(labelText: "Focus"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: shortCtrl,
              decoration: const InputDecoration(labelText: "Pause courte"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longCtrl,
              decoration: const InputDecoration(labelText: "Pause longue"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nombre de sessions avant une pause longue :"),
                Slider(
                  value: settings.longBreakEveryX.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8,
                  label: "${settings.longBreakEveryX}",
                  onChanged: (value) {
                    setState(() {
                      settings.longBreakEveryX = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // ferme la boîte
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              // Enregistre les paramètres
              settings.focusDuration = int.tryParse(focusCtrl.text) ?? 25;
              settings.shortBreakDuration = int.tryParse(shortCtrl.text) ?? 5;
              settings.longBreakDuration = int.tryParse(longCtrl.text) ?? 15;
              timer.resetTimer();

              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                await Supabase.instance.client
                    .from('pomodoro_settings')
                    .upsert({
                  'user_id': userId,
                  'focus_duration': settings.focusDuration,
                  'short_break_duration': settings.shortBreakDuration,
                  'long_break_duration': settings.longBreakDuration,
                  'long_break_every_x': settings.longBreakEveryX,
                });
              }

              Navigator.of(context).pop(); // ferme le dialog principal

              // ✅ Affiche confirmation via SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Paramètres Pomodoro enregistrés ✅"),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    ),
  );
}
