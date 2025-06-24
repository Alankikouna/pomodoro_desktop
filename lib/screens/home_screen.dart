import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/circular_timer_display.dart';
import '../models/pomodoro_settings.dart';
import '../services/app_blocker_service.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _sidebarController;
  late final AnimationController _labelAnimationController;
  late final Animation<Offset> _labelOffsetAnimation;
  late final ConfettiController _confettiController;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _labelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _labelOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _labelAnimationController,
      curve: Curves.easeOut,
    ));

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _labelAnimationController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerService>();
    final progress = timer.currentDuration.inSeconds / timer.totalDuration.inSeconds;

    if (timer.currentDuration.inSeconds == 0) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/success.mp3'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Row(
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _sidebarController,
              curve: Curves.easeOut,
            )),
            child: Container(
              width: 100,
              color: const Color(0xFFE0E0E0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => timer.switchSession(PomodoroSessionType.focus),
                    icon: const Icon(Icons.timer, color: Colors.indigo),
                    tooltip: "Focus",
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => timer.switchSession(PomodoroSessionType.shortBreak),
                    icon: const Icon(Icons.coffee, color: Colors.green),
                    tooltip: "Pause courte",
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => timer.switchSession(PomodoroSessionType.longBreak),
                    icon: const Icon(Icons.bed, color: Colors.redAccent),
                    tooltip: "Pause longue",
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => _showSettingsDialog(context, timer.settings, timer),
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    tooltip: "Modifier durées",
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => _showBlockedAppsDialog(context),
                    icon: const Icon(Icons.block, color: Colors.black87),
                    tooltip: "Apps bloquées",
                  ),
                ],
              ),
            ),
          ),

          // Main zone
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularTimerDisplay(
                        duration: timer.currentDuration,
                        progress: progress,
                        label: '',
                      ),
                      Positioned(
                        bottom: 120,
                        child: SlideTransition(
                          position: _labelOffsetAnimation,
                          child: Text(
                            timer.sessionType.name.toUpperCase(),
                            key: ValueKey(timer.sessionType),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.purple],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: timer.isRunning ? 1.0 : 1.1,
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          icon: const Icon(Icons.restart_alt),
                          iconSize: 36,
                          onPressed: timer.resetTimer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedScale(
                        scale: timer.isRunning ? 1.0 : 1.1,
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                          iconSize: 36,
                          onPressed: timer.isRunning ? timer.stopTimer : timer.startTimer,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, PomodoroSettings settings, TimerService timer) {
    final focusCtrl = TextEditingController(text: settings.focusDuration.toString());
    final shortCtrl = TextEditingController(text: settings.shortBreakDuration.toString());
    final longCtrl = TextEditingController(text: settings.longBreakDuration.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier les durées (minutes)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: focusCtrl,
              decoration: const InputDecoration(labelText: "Focus"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: shortCtrl,
              decoration: const InputDecoration(labelText: "Pause courte"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longCtrl,
              decoration: const InputDecoration(labelText: "Pause longue"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              settings.focusDuration = int.tryParse(focusCtrl.text) ?? 25;
              settings.shortBreakDuration = int.tryParse(shortCtrl.text) ?? 5;
              settings.longBreakDuration = int.tryParse(longCtrl.text) ?? 15;
              timer.resetTimer();
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _showBlockedAppsDialog(BuildContext context) {
    final blocker = AppBlockerService.instance;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Applications bloquées"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final app in blocker.bannedApps)
                ListTile(
                  title: Text(app),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      blocker.bannedApps.remove(app);
                      setState(() {});
                    },
                  ),
                ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Nom du processus (ex: Discord.exe)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
            TextButton(
              onPressed: () {
                blocker.bannedApps.add(controller.text);
                controller.clear();
                setState(() {});
              },
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}
