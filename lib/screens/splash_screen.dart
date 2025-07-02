
// Écran de démarrage (SplashScreen) qui vérifie l'authentification et charge les paramètres utilisateur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/timer_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';


/// Affiche un écran de chargement au lancement de l'app et redirige selon l'état de connexion
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


/// État de l'écran de splash : vérifie l'authentification et charge les données utilisateur
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Vérifie si l'utilisateur est connecté et redirige vers la bonne page
  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1)); // Petite pause pour l'effet splash
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return; // ✅ éviter les erreurs de contexte async

    if (session != null) {
      // Si l'utilisateur est connecté, on charge ses paramètres Pomodoro
      final timer = provider.Provider.of<TimerService>(context, listen: false);
      await timer.loadSettingsFromSupabase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Sinon, on redirige vers l'écran d'authentification
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }


  /// Affiche un indicateur de chargement pendant la vérification
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
