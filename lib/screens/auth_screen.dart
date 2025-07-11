// Écran d'authentification (connexion/inscription) avec Supabase
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // ✅ Import direct sans alias
import 'package:pomodoro_desktop/services/timer_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final client = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInOrSignUp() async {
    setState(() => _isLoading = true);
    try {
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text.trim();

      // Tentative de connexion
      final signIn = await client.auth.signInWithPassword(email: email, password: password);

      if (signIn.user == null) {
        // Si connexion échoue, inscription
        final signUp = await client.auth.signUp(email: email, password: password);
        if (signUp.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie 🎉")),
          );
        }
      }

      // ⏬ Reset l'état local puis recharge depuis Supabase
      final timerService = context.read<TimerService>();
      timerService.resetState();
      await timerService.loadSettingsFromSupabase();

      context.go('/');
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isMobile ? double.infinity : 400,
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Connexion", style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signInOrSignUp,
                            child: const Text("Connexion / Inscription"),
                          ),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text("Pas encore inscrit ? Créer un compte"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
