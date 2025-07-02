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
  /// Nombre de sessions avant une longue pause
  int longBreakEveryX;

  PomodoroSettings({
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.longBreakEveryX,
  });

  /// Renvoie les réglages par défaut (25/5/15, longue pause toutes les 4 sessions)
  factory PomodoroSettings.defaultSettings() {
    return PomodoroSettings(
      focusDuration: 25,
      shortBreakDuration: 5,
      longBreakDuration: 15,
      longBreakEveryX: 4,
    );
  }

  /// Charge les réglages sauvegardés depuis le stockage local (SharedPreferences)
  static Future<PomodoroSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PomodoroSettings(
      focusDuration: prefs.getInt('focusDuration') ?? 25,
      shortBreakDuration: prefs.getInt('shortBreakDuration') ?? 5,
      longBreakDuration: prefs.getInt('longBreakDuration') ?? 15,
      longBreakEveryX: prefs.getInt('longBreakEveryX') ?? 4,
    );
  }

  /// Sauvegarde les réglages dans le stockage local (SharedPreferences)
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focusDuration', focusDuration);
    await prefs.setInt('shortBreakDuration', shortBreakDuration);
    await prefs.setInt('longBreakDuration', longBreakDuration);
    await prefs.setInt('longBreakEveryX', longBreakEveryX);
  }
}
