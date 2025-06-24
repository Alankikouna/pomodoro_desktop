import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pomodoro_settings.dart';
import 'notification_service.dart';
import 'app_blocker_service.dart';


enum PomodoroSessionType { focus, shortBreak, longBreak }

class TimerService extends ChangeNotifier {
  PomodoroSettings settings;
  Timer? _timer; // ✅ sécurisation : plus de late
  Duration _currentDuration = Duration(minutes: 25);

  bool isRunning = false;
  PomodoroSessionType sessionType = PomodoroSessionType.focus;

  TimerService(this.settings) {
    _setInitialDuration();
  }

  Duration get currentDuration => _currentDuration;

  // Add this getter or field for totalDuration
  Duration get totalDuration => _totalDuration;

  // Make sure you have a backing field for totalDuration
  final Duration _totalDuration = const Duration(minutes: 25);

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
    _timer?.cancel(); // ✅ annulation sécurisée
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
    stopTimer(); // ✅ arrête le timer actif
    sessionType = type;
    _setInitialDuration(); // ✅ applique la bonne durée
    notifyListeners(); // ✅ mise à jour de l’UI
  }
  final AppBlockerService _blocker = AppBlockerService.instance;

}
