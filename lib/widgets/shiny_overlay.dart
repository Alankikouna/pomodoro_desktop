import 'package:flutter/material.dart';

/// Overlay animé affiché lorsque l'utilisateur tire un Pokémon "shiny".
///
/// [gifPath] : chemin vers le GIF à afficher.
/// [isShiny] : si `true`, affiche le bandeau "✨ SHINY trouvé ! ✨".
class ShinyOverlay extends StatelessWidget {
  const ShinyOverlay({super.key, required this.gifPath, this.isShiny = false});

  /// Chemin du GIF à afficher (dans assets).
  final String? gifPath;

  /// Affiche le bandeau doré si shiny.
  final bool isShiny;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer( // l'overlay ne capture pas les interactions
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bandeau "SHINY" en haut
          if (isShiny)
            Positioned(
              top: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: const Text(
                  '✨ SHINY trouvé ! ✨',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
              ),
            ),

          // GIF Pokémon en bas
          if (gifPath != null)
            Positioned(
              bottom: 0,
              child: Image.asset(gifPath!, height: 120),
            ),
        ],
      ),
    );
  }
}
