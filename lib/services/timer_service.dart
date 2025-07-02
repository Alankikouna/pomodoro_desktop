import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pomodoro_settings.dart';
import 'notification_service.dart';
import 'app_blocker_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PomodoroSessionType { focus, shortBreak, longBreak }

class TimerService extends ChangeNotifier {
  PomodoroSettings settings = PomodoroSettings(
    focusDuration: 25,
    shortBreakDuration: 5,
    longBreakDuration: 15,
  );

  Timer? _timer;
  Duration _currentDuration = const Duration(minutes: 25);
  final Duration _totalDuration = const Duration(minutes: 25);

  bool isRunning = false;
  PomodoroSessionType sessionType = PomodoroSessionType.focus;
  final AppBlockerService _blocker = AppBlockerService.instance;

  TimerService() {
    _setInitialDuration();
  }

  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  void _setInitialDuration() {
    switch (sessionType) {
      case PomodoroSessionType.focus:
        _currentDuration = Duration(minutes: settings.focusDuration);
        break;
      case PomodoroSessionType.shortBreak:
        _currentDuration = Duration(minutes: settings.shortBreakDuration);
        break;
      case PomodoroSessionType.longBreak:
        _currentDuration = Duration(minutes: settings.longBreakDuration);
        break;
    }
    notifyListeners();
  }

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _blocker.startMonitoring();

    NotificationService().showImmediateNotification(
      title: "Session démarrée",
      body: sessionType == PomodoroSessionType.focus
          ? "Travaille dur pendant ${settings.focusDuration} minutes !"
          : "Profite de ta pause :)",
    );

    NotificationService().scheduleNotification(
      title: "Session terminée",
      body: sessionType == PomodoroSessionType.focus
          ? "C’est le moment de faire une pause !"
          : "On repart au boulot 💪",
      delay: _currentDuration,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentDuration.inSeconds > 0) {
        _currentDuration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    _blocker.stopMonitoring();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _setInitialDuration();
  }

  void switchSession(PomodoroSessionType type) {
    stopTimer();
    sessionType = type;
    _setInitialDuration();
  }

  Future<void> loadSettingsFromSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('pomodoro_settings')
          .select()
          .eq('user_id', userId)
          .single();

      if (response != null) {
        settings = PomodoroSettings(
          focusDuration: response['focus_duration'],
          shortBreakDuration: response['short_break_duration'],
          longBreakDuration: response['long_break_duration'],
        );
        _setInitialDuration(); // recharge les durées
        notifyListeners();
      }
    } catch (e) {
      // Log optionnel
    }
  }

  Future<void> saveSettingsToSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('pomodoro_settings').upsert({
      'user_id': userId,
      'focus_duration': settings.focusDuration,
      'short_break_duration': settings.shortBreakDuration,
      'long_break_duration': settings.longBreakDuration,
    });
  }
}
