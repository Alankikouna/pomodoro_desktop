import 'package:flutter/material.dart';

class CircularTimerDisplay extends StatelessWidget {
  final Duration duration;
  final double progress;
  final String label;

  const CircularTimerDisplay({
    super.key,
    required this.duration,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
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
