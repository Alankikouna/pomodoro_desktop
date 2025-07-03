// Écran d'inscription utilisateur avec Supabase
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

/// Écran permettant à l'utilisateur de créer un compte via Supabase
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

/// État de l'écran d'inscription : gère la logique d'inscription et l'affichage
class _SignupScreenState extends State<SignupScreen> {
  // Contrôleurs pour les champs email et mot de passe
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  // Instance du client Supabase
  final client = Supabase.instance.client;

  /// Tente de créer un compte utilisateur avec Supabase
  Future<void> _signUp() async {
    try {
      final response = await client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Inscription réussie. Connectez-vous !")),
        );
        context.go('/auth');
      }
    } catch (e) {
      // Affiche l'erreur en cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur : ${e.toString()}")),
      );
    }
  }

  /// Construit l'interface d'inscription avec champs et bouton
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Champ email
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    // Champ mot de passe
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                    ),
                    const SizedBox(height: 20),
                    // Bouton d'inscription
                    ElevatedButton(
                      onPressed: _signUp,
                      child: const Text("Créer un compte"),
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
