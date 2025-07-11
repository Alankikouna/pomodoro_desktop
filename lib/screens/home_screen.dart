import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/timer_service.dart';
import '../widgets/header_theme_menu.dart';
import '../widgets/home_sidebar.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/timer_area.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _labelAnimationController;
  late final Animation<Offset> _labelOffsetAnimation;
  late final ConfettiController _confettiController;
  final _audioPlayer = AudioPlayer();
  final _focusNode = FocusNode();

  bool _showTiplouf = false;
  final List<_PokemonGif> _pokemons = [
    _PokemonGif('lib/assets/gif/piplup-discord.gif', 85),
    _PokemonGif('lib/assets/gif/arceus.gif', 14),
    _PokemonGif('lib/assets/gif/arceus-pokémon.gif', 1),
  ];
  String? _currentPokemonGif;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
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
    _focusNode.dispose();
    _labelAnimationController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerService>();

    if (timer.currentDuration.inSeconds == 0 &&
        _confettiController.state != ConfettiControllerState.playing &&
        !_showTiplouf) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/success.mp3'));
      setState(() {
        _currentPokemonGif = _pickRandomPokemon();
        _showTiplouf = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showTiplouf = false;
            _currentPokemonGif = null;
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const StartPauseIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyR): const ResetIntent(),
        LogicalKeySet(LogicalKeyboardKey.digit1): const SwitchToFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.digit2): const SwitchToShortBreakIntent(),
        LogicalKeySet(LogicalKeyboardKey.digit3): const SwitchToLongBreakIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyS): const OpenSettingsIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyB): const OpenBlockerIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyH): const OpenHistoryIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          StartPauseIntent: CallbackAction(onInvoke: (_) {
            timer.isRunning ? timer.stopTimer() : timer.startTimer();
            return null;
          }),
          ResetIntent: CallbackAction(onInvoke: (_) {
            timer.resetTimer();
            return null;
          }),
          SwitchToFocusIntent: CallbackAction(
              onInvoke: (_) => timer.switchSession(PomodoroSessionType.focus)),
          SwitchToShortBreakIntent: CallbackAction(
              onInvoke: (_) => timer.switchSession(PomodoroSessionType.shortBreak)),
          SwitchToLongBreakIntent: CallbackAction(
              onInvoke: (_) => timer.switchSession(PomodoroSessionType.longBreak)),
          OpenSettingsIntent: CallbackAction(onInvoke: (_) {
            showSettingsDialog(context, timer.settings, timer);
            return null;
          }),
          OpenBlockerIntent: CallbackAction(onInvoke: (_) {
            context.go('/blocker');
            return null;
          }),
          OpenHistoryIntent: CallbackAction(onInvoke: (_) {
            context.go('/history');
            return null;
          }),
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pomodoro Desktop'),
            actions: const [HeaderThemeMenu()],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Focus(
            focusNode: _focusNode,
            autofocus: true,
            child: Row(
              children: [
                HomeSidebar(
                  current: timer.sessionType,
                  onSwitch: timer.switchSession,
                  onSettings: () => showSettingsDialog(context, timer.settings, timer),
                ),
                Expanded(
                  child: Center(
                    child: TimerArea(
                      current: timer.currentDuration,
                      total: timer.totalDuration,
                      type: timer.sessionType,
                      showPokemon: _showTiplouf,
                      pokemonGif: _currentPokemonGif,
                      confetti: _confettiController,
                      reset: timer.resetTimer,
                      playPause: timer.isRunning ? timer.stopTimer : timer.startTimer,
                      isRunning: timer.isRunning,
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

  String _pickRandomPokemon() {
    final total = _pokemons.fold<int>(0, (sum, p) => sum + p.chance);
    final rand = _random.nextInt(total);
    int cumulative = 0;
    for (final poke in _pokemons) {
      cumulative += poke.chance;
      if (rand < cumulative) {
        return poke.assetPath;
      }
    }
    return _pokemons.first.assetPath;
  }
}

// Raccourcis clavier personnalisés
class StartPauseIntent extends Intent {
  const StartPauseIntent();
}

class ResetIntent extends Intent {
  const ResetIntent();
}

class SwitchToFocusIntent extends Intent {
  const SwitchToFocusIntent();
}

class SwitchToShortBreakIntent extends Intent {
  const SwitchToShortBreakIntent();
}

class SwitchToLongBreakIntent extends Intent {
  const SwitchToLongBreakIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class OpenBlockerIntent extends Intent {
  const OpenBlockerIntent();
}

class OpenHistoryIntent extends Intent {
  const OpenHistoryIntent();
}

class _PokemonGif {
  final String assetPath;
  final int chance;
  _PokemonGif(this.assetPath, this.chance);
}
