
// Service de gestion du minuteur Pomodoro, notifications et blocage d'applications
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pomodoro_settings.dart';
import 'notification_service.dart';
import 'app_blocker_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Types de session Pomodoro
enum PomodoroSessionType { focus, shortBreak, longBreak }


/// Service principal pour gérer le minuteur Pomodoro, les notifications et le blocage d'applications
class TimerService extends ChangeNotifier {
  /// Paramètres utilisateur pour les durées des sessions
  PomodoroSettings settings = PomodoroSettings(
    focusDuration: 25,
    shortBreakDuration: 5,
    longBreakDuration: 15,
  );

  Timer? _timer; // Timer du compte à rebours
  Duration _currentDuration = const Duration(minutes: 25); // Durée restante
  final Duration _totalDuration = const Duration(minutes: 25); // Durée totale de la session

  bool isRunning = false; // Indique si le minuteur est en cours
  PomodoroSessionType sessionType = PomodoroSessionType.focus; // Type de session actuelle
  final AppBlockerService _blocker = AppBlockerService.instance; // Service de blocage d'apps

  /// Constructeur : initialise la durée selon le type de session
  TimerService() {
    _setInitialDuration();
  }


  /// Durée restante de la session en cours
  Duration get currentDuration => _currentDuration;
  /// Durée totale de la session
  Duration get totalDuration => _totalDuration;


  /// Définit la durée initiale selon le type de session
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

  /// Démarre le minuteur Pomodoro, bloque les apps et programme les notifications
  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _blocker.startMonitoring(); // Active le blocage d'applications

    // Notification immédiate de début de session
    NotificationService().showImmediateNotification(
      title: "Session démarrée",
      body: sessionType == PomodoroSessionType.focus
          ? "Travaille dur pendant ${settings.focusDuration} minutes !"
          : "Profite de ta pause :)",
    );

    // Notification programmée pour la fin de session
    NotificationService().scheduleNotification(
      title: "Session terminée",
      body: sessionType == PomodoroSessionType.focus
          ? "C’est le moment de faire une pause !"
          : "On repart au boulot 💪",
      delay: _currentDuration,
    );

    // Décrémente la durée chaque seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentDuration.inSeconds > 0) {
        _currentDuration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stopTimer();
      }
    });
  }


  /// Arrête le minuteur et le blocage d'applications
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    _blocker.stopMonitoring();
    notifyListeners();
  }


  /// Réinitialise le minuteur à la durée initiale de la session
  void resetTimer() {
    stopTimer();
    _setInitialDuration();
  }


  /// Change le type de session (focus, pause courte, pause longue)
  void switchSession(PomodoroSessionType type) {
    stopTimer();
    sessionType = type;
    _setInitialDuration();
  }


  /// Charge les paramètres Pomodoro de l'utilisateur depuis Supabase
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

  /// Sauvegarde les paramètres Pomodoro de l'utilisateur dans Supabase
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
