// Service pour surveiller l'activité de l'utilisateur et détecter l'inactivité (Windows)
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';

import 'notification_service.dart';


/// Service qui surveille l'inactivité de l'utilisateur et notifie après un certain seuil
class ActivityService extends ChangeNotifier {
  /// Seuil d'inactivité avant notification (5 minutes)
  static const idleThreshold = Duration(minutes: 5); // ⏱️ seuil d'inactivité
  Timer? _pollTimer; // Timer pour le polling périodique
  Duration idleTime = Duration.zero; // Durée d'inactivité actuelle


  /// Démarre la surveillance de l'inactivité utilisateur
  void startMonitoring() {
    _pollTimer?.cancel();
    // Vérifie toutes les 5 secondes l'inactivité
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final lastInput = _getIdleDuration();
      idleTime = Duration(milliseconds: lastInput);
      if (idleTime >= idleThreshold) {
        _onUserIdle();
      }
    });
  }


  /// Arrête la surveillance de l'inactivité
  void stopMonitoring() {
    _pollTimer?.cancel();
  }


  /// Récupère le temps d'inactivité en millisecondes (Windows uniquement)
  /// Utilise l'API Win32 pour obtenir le temps depuis la dernière entrée utilisateur
  int _getIdleDuration() {
    final struct = calloc<LASTINPUTINFO>();
    struct.ref.cbSize = sizeOf<LASTINPUTINFO>();
    final success = GetLastInputInfo(struct);

    if (success == 0) {
      calloc.free(struct);
      return 0;
    }

    final tickCount = GetTickCount();
    final lastInputTick = struct.ref.dwTime;
    calloc.free(struct);

    return tickCount - lastInputTick;
  }

  /// Appelé lorsque l'utilisateur est inactif depuis le seuil défini
  void _onUserIdle() {
    debugPrint("💤 Inactivité détectée depuis $idleTime");

    // Affiche une notification à l'utilisateur
    NotificationService().showImmediateNotification(
      title: "Inactivité détectée",
      body: "Tu es inactif depuis plus de 5 minutes. Besoin d'une pause ?",
    );

    // Notifie les listeners (widgets, etc.)
    notifyListeners();
  }
}

class InactivityService {
  final Duration timeout;
  final VoidCallback onInactivity;

  Timer? _inactivityTimer;

  InactivityService({
    required this.timeout,
    required this.onInactivity,
  });

  void initialize(BuildContext context) {
    _resetTimer();
    WidgetsBinding.instance.addObserver(_LifecycleEventHandler(
      onUserInteraction: _resetTimer,
    ));
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeout, onInactivity);
  }

  void dispose() {
    _inactivityTimer?.cancel();
  }
}

class _LifecycleEventHandler extends WidgetsBindingObserver {
  final VoidCallback onUserInteraction;

  _LifecycleEventHandler({required this.onUserInteraction});

  @override
  void didChangeMetrics() {
    onUserInteraction();
  }

  @override
  void didHaveMemoryPressure() {
    onUserInteraction();
  }
}
