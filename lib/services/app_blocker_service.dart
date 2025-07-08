// Service pour bloquer (fermer) automatiquement des applications Windows
import 'dart:async';
import 'dart:io';

enum BlockerState { idle, running }

class AppBlockerService {
  /* ─────────── SINGLETON ─────────── */
  static final AppBlockerService instance = AppBlockerService._internal();
  AppBlockerService._internal();

  /* ─────────── LISTES ─────────── */
  /// Liste des executables bloqués (modifiable à chaud depuis l’UI)
  final List<String> bannedApps = ['Discord.exe'];

  /* ─────────── SURVEILLANCE ─────────── */
  BlockerState state = BlockerState.idle;
  Timer? _timer;                // timer périodique (10 s)

  /// Active / désactive la surveillance.
  void toggleMonitoring(bool enable) {
    if (enable && state == BlockerState.idle) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => _scanAndKill());
      state = BlockerState.running;
      print('🛡️ Blocage ACTIF (focus)');
    } else if (!enable && state == BlockerState.running) {
      _timer?.cancel();
      _timer = null;
      state = BlockerState.idle;
      print('🛑 Blocage désactivé');
    }
  }

  /// Ferme les apps bannies si elles tournent.
  Future<void> _scanAndKill() async {
    final running = await getRunningApps();
    for (final exe in bannedApps) {
      if (running.contains(exe)) {
        await Process.run('taskkill', ['/F', '/IM', exe]);
        print('🚫 $exe fermé automatiquement');
      }
    }
  }

  /* ─────────── APPS EN COURS ─────────── */
  /// Retourne la liste des exécutables (.exe) actuellement lancés.
  Future<List<String>> getRunningApps() async {
    final result = await Process.run('tasklist', ['/fo', 'csv', '/nh']);
    final lines = result.stdout.toString().split('\n');
    // Chaque ligne CSV : "Image Name","PID",...
    final apps = <String>{
      for (final l in lines)
        if (l.trim().isNotEmpty)
          l.split('","').first.replaceAll('"', '').trim()
    };
    return apps.toList()..sort();
  }
}
