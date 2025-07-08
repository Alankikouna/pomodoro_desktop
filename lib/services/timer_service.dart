// Service de gestion du minuteur Pomodoro, notifications et blocage d'applications
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pomodoro_settings.dart';
import 'notification_service.dart';
import 'app_blocker_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PomodoroSessionType { focus, shortBreak, longBreak }

class TimerService extends ChangeNotifier {
  /* ─────────── PARAMÈTRES ─────────── */
  PomodoroSettings settings = PomodoroSettings(
    focusDuration: 25,
    shortBreakDuration: 5,
    longBreakDuration: 15,
    longBreakEveryX: 4,
  );

  PomodoroSessionType sessionType = PomodoroSessionType.focus;
  Duration _currentDuration = const Duration(minutes: 25);
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration =>
      Duration(minutes: _minutesForType(sessionType, settings));

  Timer? _timer;
  bool isRunning = false;

  final AppBlockerService _blocker = AppBlockerService.instance;

  DateTime? _sessionStart;
  int _sessionCount = 0;

  TimerService() {
    _setInitialDuration();
  }

  /* ─────────── INITIALISATION ─────────── */
  void _setInitialDuration() {
    _currentDuration =
        Duration(minutes: _minutesForType(sessionType, settings));
    notifyListeners();
  }

  static int _minutesForType(
      PomodoroSessionType type, PomodoroSettings settings) {
    switch (type) {
      case PomodoroSessionType.focus:
        return settings.focusDuration;
      case PomodoroSessionType.shortBreak:
        return settings.shortBreakDuration;
      case PomodoroSessionType.longBreak:
        return settings.longBreakDuration;
    }
  }

  /* ─────────── DÉMARRER / ARRÊTER ─────────── */
  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _sessionStart = DateTime.now();

    // Blocage uniquement si session Focus
    _blocker.toggleMonitoring(sessionType == PomodoroSessionType.focus);

    // Notifications
    NotificationService().showImmediateNotification(
      title: "Session démarrée",
      body: sessionType == PomodoroSessionType.focus
          ? "Travaille dur pendant ${settings.focusDuration} minutes !"
          : "Profite de ta pause 🙂",
    );
    NotificationService().scheduleNotification(
      title: "Session terminée",
      body: sessionType == PomodoroSessionType.focus
          ? "C’est le moment de faire une pause !"
          : "On repart au boulot 💪",
      delay: _currentDuration,
    );

    // Tick 1 s
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentDuration.inSeconds > 0) {
        _currentDuration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stopTimer();

        // Enchaîne automatiquement
        if (sessionType == PomodoroSessionType.focus) {
          _sessionCount++;
          (_sessionCount % settings.longBreakEveryX == 0)
              ? startLongBreak()
              : startShortBreak();
        } else {
          startFocus();
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;

    // Désactive toujours le blocage en fin de session
    _blocker.toggleMonitoring(false);

    // Log si la session est allée jusqu’au bout
    if (_sessionStart != null && _currentDuration.inSeconds == 0) {
      logSessionToSupabase(_sessionStart!, DateTime.now(), sessionType);
    }
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _setInitialDuration();
  }

  /// Met en pause le minuteur Pomodoro en cours.
  void pause() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    // Désactive le blocage d'applications pendant la pause
    _blocker.toggleMonitoring(false);
    notifyListeners();
  }

  /* ─────────── CHANGEMENT DE SESSION ─────────── */
  void switchSession(PomodoroSessionType newType) {
    sessionType = newType;
    _setInitialDuration();
    _blocker.toggleMonitoring(newType == PomodoroSessionType.focus);
  }

  void startFocus() {
    sessionType = PomodoroSessionType.focus;
    _setInitialDuration();
    startTimer();
  }

  void startShortBreak() {
    sessionType = PomodoroSessionType.shortBreak;
    _setInitialDuration();
    startTimer();
  }

  void startLongBreak() {
    sessionType = PomodoroSessionType.longBreak;
    _setInitialDuration();
    startTimer();
  }

  /* ─────────── SUPABASE : SETTINGS & LOGS ─────────── */
  Future<void> loadSettingsFromSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final resp = await Supabase.instance.client
          .from('pomodoro_settings')
          .select()
          .eq('user_id', userId)
          .single();

      if (resp != null) {
        settings = PomodoroSettings(
          focusDuration: resp['focus_duration'],
          shortBreakDuration: resp['short_break_duration'],
          longBreakDuration: resp['long_break_duration'],
          longBreakEveryX: resp['long_break_every_x'] ?? 4,
        );
        _setInitialDuration();
      }
    } catch (_) {
      // ignore : settings par défaut
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
      'long_break_every_x': settings.longBreakEveryX,
    });
  }

  Future<void> logSessionToSupabase(
      DateTime start, DateTime end, PomodoroSessionType type) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('pomodoro_sessions').insert({
      'user_id': userId,
      'type': type.name,
      'started_at': start.toIso8601String(),
      'ended_at': end.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchSessionHistory() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await Supabase.instance.client
        .from('pomodoro_sessions')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /* ─────────── SUPABASE : SUPPRESSION ─────────── */
  Future<void> deleteAllSessions() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client
        .from('pomodoro_sessions')
        .delete()
        .eq('user_id', userId);
  }

  Future<void> deleteSessionsBetween(DateTime from, DateTime to) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client
        .from('pomodoro_sessions')
        .delete()
        .eq('user_id', userId)
        .gte('started_at', from.toIso8601String())
        .lte('started_at', to.toIso8601String());
  }
}
