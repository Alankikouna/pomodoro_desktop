import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';

import 'notification_service.dart';

class ActivityService extends ChangeNotifier {
  static const idleThreshold = Duration(minutes: 5); // ⏱️ seuil d'inactivité
  Timer? _pollTimer;
  Duration idleTime = Duration.zero;

  void startMonitoring() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final lastInput = _getIdleDuration();
      idleTime = Duration(milliseconds: lastInput);
      if (idleTime >= idleThreshold) {
        _onUserIdle();
      }
    });
  }

  void stopMonitoring() {
    _pollTimer?.cancel();
  }

  /// Récupère le temps d'inactivité en millisecondes (Windows only)
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

  void _onUserIdle() {
    debugPrint("💤 Inactivité détectée depuis $idleTime");

    NotificationService().showImmediateNotification(
      title: "Inactivité détectée",
      body: "Tu es inactif depuis plus de 5 minutes. Besoin d'une pause ?",
    );

    notifyListeners();
  }
}
