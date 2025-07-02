
// Modèle pour stocker et charger les réglages Pomodoro (durées focus/pause)
import 'package:shared_preferences/shared_preferences.dart';


/// Modèle représentant les réglages Pomodoro (durées en minutes)
class PomodoroSettings {
  /// Durée de la session de focus (en minutes)
  int focusDuration;
  /// Durée de la pause courte (en minutes)
  int shortBreakDuration;
  /// Durée de la pause longue (en minutes)
  int longBreakDuration;

  PomodoroSettings({
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
  });


  /// Renvoie les réglages par défaut (25/5/15)
  factory PomodoroSettings.defaultSettings() {
    return PomodoroSettings(
      focusDuration: 25,
      shortBreakDuration: 5,
      longBreakDuration: 15,
    );
  }


  /// Charge les réglages sauvegardés depuis le stockage local (SharedPreferences)
  static Future<PomodoroSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PomodoroSettings(
      focusDuration: prefs.getInt('focus') ?? 25,
      shortBreakDuration: prefs.getInt('short') ?? 5,
      longBreakDuration: prefs.getInt('long') ?? 15,
    );
  }

  /// Sauvegarde les réglages dans le stockage local (SharedPreferences)
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus', focusDuration);
    await prefs.setInt('short', shortBreakDuration);
    await prefs.setInt('long', longBreakDuration);
  }
}
