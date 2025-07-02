// Écran principal de l'application Pomodoro Desktop : gestion du minuteur, des réglages et des apps bloquées
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/circular_timer_display.dart';
import '../models/pomodoro_settings.dart';
import '../services/app_blocker_service.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; 
import 'package:flutter/services.dart';



/// Écran principal affichant le minuteur Pomodoro, les boutons de session, les réglages et la déconnexion
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


/// État de l'écran principal : gère les animations, le son, la confetti et les interactions
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Contrôleur pour l'animation de la barre latérale
  late final AnimationController _sidebarController;
  // Contrôleur et animation pour le label de session
  late final AnimationController _labelAnimationController;
  late final Animation<Offset> _labelOffsetAnimation;
  // Contrôleur pour les confettis
  late final ConfettiController _confettiController;
  // Lecteur audio pour le son de succès
  final _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    // Animation d'entrée de la barre latérale
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    // Animation pour le label de session
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

    // Contrôleur pour les confettis de fin de session
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

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyR): const ResetIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              if (timer.isRunning) {
                timer.stopTimer();
              } else {
                timer.startTimer();
              }
              return null;
            },
          ),
          ResetIntent: CallbackAction<ResetIntent>(
            onInvoke: (intent) {
              timer.resetTimer();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F4F4),
            body: Row(
              children: [
                // Barre latérale avec boutons de session, réglages, apps bloquées et déconnexion
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
                        // Bouton focus
                        IconButton(
                          onPressed: () => timer.switchSession(PomodoroSessionType.focus),
                          icon: const Icon(Icons.timer, color: Colors.indigo),
                          tooltip: "Focus",
                        ),
                        const SizedBox(height: 16),
                        // Bouton pause courte
                        IconButton(
                          onPressed: () => timer.switchSession(PomodoroSessionType.shortBreak),
                          icon: const Icon(Icons.coffee, color: Colors.green),
                          tooltip: "Pause courte",
                        ),
                        const SizedBox(height: 16),
                        // Bouton pause longue
                        IconButton(
                          onPressed: () => timer.switchSession(PomodoroSessionType.longBreak),
                          icon: const Icon(Icons.bed, color: Colors.redAccent),
                          tooltip: "Pause longue",
                        ),
                        const SizedBox(height: 16),
                        // Bouton réglages
                        IconButton(
                          onPressed: () => _showSettingsDialog(context, timer.settings, timer),
                          icon: const Icon(Icons.tune, color: Colors.grey),
                          tooltip: "Modifier durées",
                        ),
                        const SizedBox(height: 16),
                        // Bouton apps bloquées
                        IconButton(
                          onPressed: () => _showBlockedAppsDialog(context),
                          icon: const Icon(Icons.block, color: Colors.black87),
                          tooltip: "Apps bloquées",
                        ), 
                        const SizedBox(height: 16),
                        // Bouton historique
                        IconButton(
                          onPressed: () => _showHistoryDialog(context),
                          icon: const Icon(Icons.history, color: Colors.deepOrange),
                          tooltip: "Historique",
                        ),
                        const SizedBox(height: 16),
                        // Bouton déconnexion
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => _logout(context),
                          tooltip: 'Déconnexion',
                        ),
                      ],
                    ),
                  ),
                ),

                // Zone principale : minuteur, label, confettis, boutons de contrôle
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      children: [
                        const Spacer(),

                        // Minuteur circulaire et label animé
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
                            // Confettis de fin de session
                            ConfettiWidget(
                              confettiController: _confettiController,
                              blastDirectionality: BlastDirectionality.explosive,
                              shouldLoop: false,
                              colors: const [Colors.green, Colors.blue, Colors.orange, Colors.purple],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Boutons de contrôle (reset, play/pause)
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
          ),
        ),
      ),
    );
  }


  /// Affiche la boîte de dialogue pour modifier les durées Pomodoro
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
            // Champ focus
            TextField(
              controller: focusCtrl,
              decoration: const InputDecoration(labelText: "Focus"),
              keyboardType: TextInputType.number,
            ),
            // Champ pause courte
            TextField(
              controller: shortCtrl,
              decoration: const InputDecoration(labelText: "Pause courte"),
              keyboardType: TextInputType.number,
            ),
            // Champ pause longue
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
            onPressed: () async {
              // Met à jour les réglages et sauvegarde dans Supabase
              settings.focusDuration = int.tryParse(focusCtrl.text) ?? 25;
              settings.shortBreakDuration = int.tryParse(shortCtrl.text) ?? 5;
              settings.longBreakDuration = int.tryParse(longCtrl.text) ?? 15;
              timer.resetTimer();

              // 🔐 Sauvegarde dans Supabase
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                await Supabase.instance.client
                    .from('pomodoro_settings')
                    .upsert({
                      'user_id': userId,
                      'focus_duration': settings.focusDuration,
                      'short_break_duration': settings.shortBreakDuration,
                      'long_break_duration': settings.longBreakDuration,
                    });
              }

              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }


  /// Affiche la boîte de dialogue pour gérer la liste des applications bloquées
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
              // Liste des apps bloquées avec suppression possible
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
              // Champ pour ajouter une nouvelle app
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

  /// Affiche l'historique des sessions Pomodoro
  void _showHistoryDialog(BuildContext context) async {
    final timer = context.read<TimerService>();
    final sessions = await timer.fetchSessionHistory();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Historique des sessions"),
        content: SizedBox(
          width: 350,
          child: sessions.isEmpty
              ? const Text("Aucune session enregistrée.")
              : ListView(
                  shrinkWrap: true,
                  children: sessions.map((s) => ListTile(
                    title: Text(s['type']),
                    subtitle: Text(
                      "Début : ${s['started_at']}\nFin : ${s['ended_at']}",
                    ),
                  )).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  /// Déconnecte l'utilisateur et redirige vers la page d'authentification
  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    // Redirection vers la page d'authentification
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }
}

class ActivateIntent extends Intent {
  const ActivateIntent();
}

class ResetIntent extends Intent {
  const ResetIntent();
}
