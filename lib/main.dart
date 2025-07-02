// Point d'entrée principal de l'application Pomodoro Desktop
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/timer_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';


/// Initialise Flutter, Supabase et lance l'application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://czxibvxxxfcxhsgrteea.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6eGlidnh4eGZjeGhzZ3J0ZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NTY4MTIsImV4cCI6MjA2NjMzMjgxMn0.0tv6cr2s-RgziLhN9V4vHUV3vq_KC5y6ItYPFjepXbE',
  );
  runApp(const MyApp());
}


/// Widget racine de l'application : fournit le TimerService et configure le thème
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerService(), // Fournit le service Pomodoro à toute l'app
      child: MaterialApp(
        title: 'Pomodoro Desktop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/auth': (context) => const AuthScreen(),
          '/signup': (context) => const SignupScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}
