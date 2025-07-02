
// Écran d'authentification (connexion/inscription) avec Supabase
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Écran permettant à l'utilisateur de se connecter ou de s'inscrire
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}


/// État de l'écran d'authentification : gère la logique de connexion/inscription
class _AuthScreenState extends State<AuthScreen> {
  // Contrôleurs pour les champs email et mot de passe
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  // Instance du client Supabase
  final client = Supabase.instance.client;
  // Indique si une requête est en cours
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  /// Tente de se connecter, sinon inscrit l'utilisateur
  Future<void> _signInOrSignUp() async {
    setState(() => _isLoading = true);
    try {
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text.trim();

      // Tente la connexion
      final signIn = await client.auth.signInWithPassword(email: email, password: password);

      if (signIn.user == null) {
        // Connexion échouée, tentative d'inscription
        final signUp = await client.auth.signUp(email: email, password: password);
        if (signUp.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie 🎉")),
          );
        }
      }

      // Redirige vers la page d'accueil
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      // Affiche le message d'erreur d'authentification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      // Affiche toute autre erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  /// Construit l'interface de connexion/inscription
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Champ email
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                // Champ mot de passe
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Bouton de connexion/inscription ou loader
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signInOrSignUp,
                        child: const Text("Connexion / Inscription"),
                      ),
                // Lien vers la page d'inscription
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text("Pas encore inscrit ? Créer un compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
