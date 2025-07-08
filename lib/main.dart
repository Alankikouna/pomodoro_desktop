import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';
import 'services/theme_service.dart';
import 'services/timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Supabase
  await Supabase.initialize(
    url: 'https://czxibvxxxfcxhsgrteea.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6eGlidnh4eGZjeGhzZ3J0ZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NTY4MTIsImV4cCI6MjA2NjMzMjgxMn0.0tv6cr2s-RgziLhN9V4vHUV3vq_KC5y6ItYPFjepXbE',
  );

  final themeService = ThemeService();
  await themeService.load();

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => TimerService()),
        provider.ChangeNotifierProvider.value(value: themeService),
      ],
      child: const PomodoroApp(),
    ),
  );
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = provider.Provider.of<ThemeService>(context);

    return MaterialApp.router(
      title: 'Pomodoro Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white70),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Color(0xFFBB86FC),   // Violet doux
          secondary: Color(0xFF03DAC6), // Bleu-vert clair
        ),
      ),
      themeMode: themeService.materialMode,
      routerConfig: appRouter,
    );
  }
}
