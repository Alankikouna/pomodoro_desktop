import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/timer_service.dart';
import 'models/pomodoro_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerService(
  PomodoroSettings(
    focusDuration: 25,
    shortBreakDuration: 5,
    longBreakDuration: 15,
  ),
),

      child: MaterialApp(
        title: 'Pomodoro Desktop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
