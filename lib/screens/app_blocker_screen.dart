import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/app_blocker_service.dart';
import '../widgets/exe_tile.dart';            

/// Écran dédié à la gestion et au blocage d'applications (Windows)
class AppBlockerScreen extends StatefulWidget {
  const AppBlockerScreen({super.key});

  @override
  State<AppBlockerScreen> createState() => _AppBlockerScreenState();
}

class _AppBlockerScreenState extends State<AppBlockerScreen> {
  final _blocker = AppBlockerService.instance;
  List<String> _running = [];
  String _searchQuery = '';
  final TextEditingController _manualAddController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshRunning();
  }

  /* ─────────── Processus actifs ─────────── */
  Future<void> _refreshRunning() async {
    final result = await Process.run('tasklist', ['/fo', 'csv', '/nh']);
    final procs = result.stdout
        .toString()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => l.split('"')[1])          // "Image Name"
        .where((name) => name.endsWith('.exe'))
        .toSet()
        .toList()
      ..sort();
    setState(() => _running = procs);
  }

  void _add(String exe) {
    if (!_blocker.bannedApps.contains(exe)) {
      setState(() => _blocker.bannedApps.add(exe));
    }
  }

  Future<void> _remove(String exe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer $exe de la liste ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _blocker.bannedApps.remove(exe));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps =
        _running.where((app) => app.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.go('/home'),
        ),
        title: const Text("Blocage d'applications"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir', onPressed: _refreshRunning),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /* ======== APPS ACTIVES ======== */
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Applications en cours', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher une application...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredApps.isEmpty
                        ? const Center(child: Text('Aucune app détectée'))
                        : ListView.separated(
                            itemCount: filteredApps.length,
                            separatorBuilder: (_, __) => const Divider(height: 0),
                            itemBuilder: (context, i) {
                              final app = filteredApps[i];
                              final isBlocked = _blocker.bannedApps.contains(app);
                              return ExeTile(                      
                                exeName: app,
                                isBlocked: isBlocked,
                                onAdd: isBlocked ? null : () => _add(app),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manualAddController,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter manuellement un .exe',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      final exe = value.trim();
                      if (exe.isNotEmpty && !_blocker.bannedApps.contains(exe)) {
                        _add(exe);
                        _manualAddController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 32),
            /* ======== APPS BLOQUÉES ======== */
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Applications bloquées', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _blocker.bannedApps.isEmpty
                        ? const Center(child: Text('Liste vide'))
                        : ListView.separated(
                            itemCount: _blocker.bannedApps.length,
                            separatorBuilder: (_, __) => const Divider(height: 0),
                            itemBuilder: (context, i) {
                              final app = _blocker.bannedApps[i];
                              return ExeTile(                // ✅ utilisation ExeTile
                                exeName: app,
                                isBlocked: true,
                                onDelete: () => _remove(app),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
