import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import 'circular_timer_display.dart';

/// Zone centrale : minuteur circulaire + label + contrôles.
///
/// **PROPS requis**
/// - [current]  : durée restante
/// - [total]    : durée totale de la session (pour le pourcentage)
/// - [type]     : enum PomodoroSessionType (focus / short / long)
/// - [isRunning]: état du timer (true = en cours)
/// - [reset] / [playPause] : callbacks
class TimerArea extends StatelessWidget {
  const TimerArea({
    super.key,
    required this.current,
    required this.total,
    required this.type,
    required this.isRunning,
    required this.showPokemon,
    required this.pokemonGif,
    required this.confetti,
    required this.reset,
    required this.playPause,
  });

  // Durées
  final Duration current;
  final Duration total;

  // Session type
  final PomodoroSessionType type;

  // État / actions
  final bool isRunning;
  final VoidCallback reset;
  final VoidCallback playPause;

  // Pokémon / confettis
  final bool showPokemon;
  final String? pokemonGif;
  final ConfettiController confetti;

  @override
  Widget build(BuildContext context) {
    final progress = total.inSeconds == 0 ? 0.0 : current.inSeconds / total.inSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /* -------- Minuteur + overlays -------- */
        Stack(
          alignment: Alignment.center,
          children: [
            CircularTimerDisplay(
              duration: current,
              progress: progress,
              label: '',
              textStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              resetTimer: reset,
              isRunning: isRunning,
              startTimer: playPause,
              stopTimer: playPause,
            ),
            Positioned(
              bottom: 120,
              child: Text(
                type.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (showPokemon && pokemonGif != null)
              Positioned(bottom: 0, child: Image.asset(pokemonGif!, height: 120)),
            ConfettiWidget(confettiController: confetti),
          ],
        ),

        /* -------- Boutons contrôle -------- */
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              iconSize: 36,
              tooltip: 'Réinitialiser',
              onPressed: reset,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
              iconSize: 36,
              tooltip: isRunning ? 'Pause' : 'Démarrer',
              onPressed: playPause,
            ),
          ],
        ),
      ],
    );
  }
}