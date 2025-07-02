// Point d'entrée principal de l'application Pomodoro Desktop
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/timer_service.dart';
import 'router.dart'; // <-- Ajoute cet import


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
      child: MaterialApp.router(
        title: 'Pomodoro Desktop',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
