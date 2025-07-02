// Widget d'affichage circulaire du minuteur Pomodoro
import 'package:flutter/material.dart';


/// Affiche un minuteur circulaire avec le temps restant et un label
class CircularTimerDisplay extends StatelessWidget {
  /// Durée restante à afficher
  final Duration duration;
  /// Progression (0.0 à 1.0)
  final double progress;
  /// Label de la session (ex: FOCUS, PAUSE)
  final String label;
  /// Style de texte pour l'affichage du temps
  final TextStyle textStyle;
  /// Couleur de l'icône
  final Color iconColor;
  /// Fonction pour réinitialiser le minuteur
  final VoidCallback resetTimer;
  /// Indique si le minuteur est en cours d'exécution
  final bool isRunning;
  /// Fonction pour démarrer le minuteur
  final VoidCallback startTimer;
  /// Fonction pour arrêter le minuteur
  final VoidCallback stopTimer;


  /// Constructeur du widget
  const CircularTimerDisplay({
    super.key,
    required this.duration,
    required this.progress,
    required this.label,
    required this.textStyle,
    this.iconColor = Colors.black,
    required this.resetTimer,
    required this.isRunning,
    required this.startTimer,
    required this.stopTimer,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width < 600 ? 200.0 : 300.0;
    // Formate les minutes et secondes pour l'affichage
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de progression
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0), // S'assure que la valeur reste entre 0 et 1
              strokeWidth: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary, // 👈 couleur dynamique selon le thème
              ),
            ),
          ),
          // Affichage du temps et du label au centre
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$minutes:$seconds",
                style: textStyle.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
