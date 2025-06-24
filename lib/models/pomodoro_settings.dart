import 'package:shared_preferences/shared_preferences.dart';

class PomodoroSettings {
  int focusDuration;
  int shortBreakDuration;
  int longBreakDuration;

  PomodoroSettings({
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
  });

  factory PomodoroSettings.defaultSettings() {
    return PomodoroSettings(
      focusDuration: 25,
      shortBreakDuration: 5,
      longBreakDuration: 15,
    );
  }

  static Future<PomodoroSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PomodoroSettings(
      focusDuration: prefs.getInt('focus') ?? 25,
      shortBreakDuration: prefs.getInt('short') ?? 5,
      longBreakDuration: prefs.getInt('long') ?? 15,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus', focusDuration);
    await prefs.setInt('short', shortBreakDuration);
    await prefs.setInt('long', longBreakDuration);
  }
}
