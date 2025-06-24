import 'dart:async';
import 'dart:io';

class AppBlockerService {
  // Singleton
  static final AppBlockerService instance = AppBlockerService._internal();
  AppBlockerService._internal();

  // Liste des applications bannies (modifiable dynamiquement)
  final List<String> bannedApps = [
    'Discord.exe',

  ];

  Timer? _monitorTimer;

  void startMonitoring() {
    stopMonitoring(); // évite les doublons

    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      for (var app in bannedApps) {
        final result = await Process.run('tasklist', []);
        if (result.stdout.toString().contains(app)) {
          final kill = await Process.run('taskkill', ['/F', '/IM', app]);
          print('🚫 Fermeture de $app :');
          print(kill.stdout);
          print(kill.stderr);
        }
      }
    });

    print('🛡️ Blocage actif toutes les 10 secondes');
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    print('🛑 Blocage désactivé');
  }
}
