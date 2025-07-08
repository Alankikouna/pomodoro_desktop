import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/timer_service.dart';

class HomeSidebar extends StatelessWidget {
  final PomodoroSessionType current;
  final void Function(PomodoroSessionType) onSwitch;
  final VoidCallback onSettings;
  const HomeSidebar({
    super.key,
    required this.current,
    required this.onSwitch,
    required this.onSettings,
  });

  Color _color(BuildContext ctx, PomodoroSessionType t) =>
      current == t ? Theme.of(ctx).colorScheme.primary : Theme.of(ctx).iconTheme.color!;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: Icon(Icons.timer,  color: _color(context, PomodoroSessionType.focus)),
              onPressed: () => onSwitch(PomodoroSessionType.focus)),
          const SizedBox(height: 16),
          IconButton(icon: Icon(Icons.coffee, color: _color(context, PomodoroSessionType.shortBreak)),
              onPressed: () => onSwitch(PomodoroSessionType.shortBreak)),
          const SizedBox(height: 16),
          IconButton(icon: Icon(Icons.bed,    color: _color(context, PomodoroSessionType.longBreak)),
              onPressed: () => onSwitch(PomodoroSessionType.longBreak)),
          const SizedBox(height: 16),
          IconButton(icon: const Icon(Icons.tune), onPressed: onSettings),
          const SizedBox(height: 16),
          IconButton(icon: const Icon(Icons.block),    onPressed: () => context.go('/blocker')),
          const SizedBox(height: 16),
          IconButton(icon: const Icon(Icons.history),  onPressed: () => context.go('/history')),
          const SizedBox(height: 16),
          IconButton(icon: const Icon(Icons.logout),   onPressed: () => context.go('/auth')),
        ],
      ),
    );
  }
}
