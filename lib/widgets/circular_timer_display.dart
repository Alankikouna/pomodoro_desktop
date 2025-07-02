
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


  /// Constructeur du widget
  const CircularTimerDisplay({
    super.key,
    required this.duration,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Formate les minutes et secondes pour l'affichage
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de progression
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0), // S'assure que la valeur reste entre 0 et 1
              strokeWidth: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
          // Affichage du temps et du label au centre
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$minutes:$seconds",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(fontSize: 16, letterSpacing: 2),
              ),
            ],
          )
        ],
      ),
    );
  }
}
