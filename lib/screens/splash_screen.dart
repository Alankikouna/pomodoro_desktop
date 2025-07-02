// Écran de démarrage (SplashScreen) qui vérifie l'authentification et charge les paramètres utilisateur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../services/timer_service.dart';


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
    await Future.delayed(const Duration(seconds: 1));
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;

    if (session != null) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client
          .from('pomodoro_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Première connexion : crée la ligne et affiche l’onboarding
        await Supabase.instance.client
            .from('pomodoro_settings')
            .upsert({
              'user_id': userId,
              'focus_duration': 25,
              'short_break_duration': 5,
              'long_break_duration': 15,
              'has_seen_onboarding': false, // <-- false ici !
            });
        context.go('/onboarding');
        return;
      }

      final hasSeenOnboarding = response['has_seen_onboarding'] ?? false;
      print('DEBUG: hasSeenOnboarding = $hasSeenOnboarding');
      if (!hasSeenOnboarding) {
        print('DEBUG: Redirection vers onboarding');
        context.go('/onboarding');
        return;
      }

      final timer = provider.Provider.of<TimerService>(context, listen: false);
      await timer.loadSettingsFromSupabase();
      context.go('/home');
    } else {
      if (!mounted) return;
      context.go('/auth');
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
