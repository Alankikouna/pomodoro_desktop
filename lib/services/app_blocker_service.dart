
// Service pour bloquer les applications indésirables en les fermant automatiquement (Windows)
import 'dart:async';
import 'dart:io';


/// Service qui surveille et ferme les applications bannies
class AppBlockerService {
  // Singleton pour garantir une seule instance du service
  static final AppBlockerService instance = AppBlockerService._internal();
  AppBlockerService._internal();


  /// Liste des applications bannies (modifiable dynamiquement)
  /// Ajouter ici les noms des exécutables à bloquer (ex: 'Discord.exe')
  final List<String> bannedApps = [
    'Discord.exe',
    // Ajouter d'autres exécutables si besoin
  ];


  Timer? _monitorTimer; // Timer pour la surveillance périodique


  /// Démarre la surveillance et le blocage des applications bannies
  void startMonitoring() {
    stopMonitoring(); // évite les doublons

    // Vérifie toutes les 10 secondes si une app bannie est lancée
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      for (var app in bannedApps) {
        // Liste les processus en cours
        final result = await Process.run('tasklist', []);
        if (result.stdout.toString().contains(app)) {
          // Si l'app est trouvée, on la ferme
          final kill = await Process.run('taskkill', ['/F', '/IM', app]);
          print('🚫 Fermeture de $app :');
          print(kill.stdout);
          print(kill.stderr);
        }
      }
    });

    print('🛡️ Blocage actif toutes les 10 secondes');
  }


  /// Arrête la surveillance des applications bannies
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    print('🛑 Blocage désactivé');
  }
}
