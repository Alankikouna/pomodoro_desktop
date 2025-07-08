import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'timer_service.dart';

/// Modes gérés dans l’app.
///
/// • system : suit le thème de l’OS  
/// • light  : forçage clair  
/// • dark   : forçage sombre
enum AppThemeMode { system, light, dark }

class ThemeService extends ChangeNotifier {
  /* ─────────── PERSISTENCE ─────────── */
  static const _keyMode  = 'theme_mode';
  static const _keySeed  = 'theme_seed';           // 🔹 nouvelle clé pour la couleur primaire
  static const _defaultSeed = 0xff6750a4;          // seed Material 3 par défaut

  /* ─────────── ÉTAT COURANT ─────────── */
  AppThemeMode _mode = AppThemeMode.system;
  Color _seedColor   = const Color(_defaultSeed);

  AppThemeMode get themeMode => _mode;
  Color get seedColor       => _seedColor;

  ThemeMode get materialMode => switch (_mode) {
        AppThemeMode.light  => ThemeMode.light,
        AppThemeMode.dark   => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };

  /* ─────────── PUBLIC API ─────────── */

  /// Charge les préférences sauvegardées (mode + seed color).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode      = AppThemeMode.values[prefs.getInt(_keyMode) ?? 0];
    final seed = prefs.getInt(_keySeed) ?? _defaultSeed;
    _seedColor = Color(seed);
    notifyListeners();
  }

  /// Change de mode (clair/sombre/système) et persiste le choix.
  Future<void> setTheme(AppThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMode, mode.index);
    notifyListeners();
  }

  /// Change la couleur d’accent principal (Material 3 “seed”) et persiste.
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeed, color.value);
    notifyListeners();
  }

  /* ─────────── AIDE UX ─────────── */

  /// Met en pause le minuteur quand la palette ou le mode change,
  /// pour éviter un éventuel clignotement durant la session Focus.
  void pauseTimerService(BuildContext context) {
    context.read<TimerService>().pause();
  }

  /* ─────────── THÈMES MATERIAL 3 ─────────── */

  /// Thème clair complet basé sur [_seedColor].
  ThemeData lightTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  /// Thème sombre complet basé sur [_seedColor].
  ThemeData darkTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
