import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

     Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur : ${e.toString()}')),
  );
}
finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
