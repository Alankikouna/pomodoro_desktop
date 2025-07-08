import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  DateTime? _fromDate;
  DateTime? _toDate;

  final _filters = {
    'all': 'Tous',
    'focus': 'Travail',
    'shortBreak': 'Pause courte',
    'longBreak': 'Pause longue',
  };

  final _fmtLong = DateFormat('dd/MM/yyyy – HH:mm');
  final _fmtShort = DateFormat('dd/MM');

  @override
  Widget build(BuildContext context) {
    final timerService = context.read<TimerService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des sessions'),
        actions: [
          // Export CSV
          IconButton(
            tooltip: 'Exporter CSV',
            icon: const Icon(Icons.download),
            onPressed: () async => _exportCsv(timerService),
          ),
          // Supprimer
          IconButton(
            tooltip: 'Tout effacer',
            icon: const Icon(Icons.delete_forever),
            onPressed: () async => _confirmAndDelete(timerService),
          ),
          // Filtre type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (v) => setState(() => _selectedFilter = v!),
              items: _filters.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: timerService.fetchSessionHistory(),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) return Center(child: Text('Erreur : ${snap.error}'));
            return const Center(child: CircularProgressIndicator());
          }

          // ----------  FILTRES  ----------
          List<Map<String, dynamic>> sessions = snap.data!;

          // Type
          if (_selectedFilter != 'all') {
            sessions = sessions.where((s) => s['type'] == _selectedFilter).toList();
          }
          // Date intervalle
          if (_fromDate != null) {
            sessions = sessions.where((s) =>
              DateTime.parse(s['started_at']).isAfter(_fromDate!) ||
              DateTime.parse(s['started_at']).isAtSameMomentAs(_fromDate!)
            ).toList();
          }
          if (_toDate != null) {
            sessions = sessions.where((s) =>
              DateTime.parse(s['started_at']).isBefore(_toDate!.add(const Duration(days:1)))
            ).toList();
          }

          if (sessions.isEmpty) {
            return const Center(child: Text('Aucune session trouvée.'));
          }

          // ----------  RÉSUMÉ  ----------
          final total = sessions.length;
          final totalMin = sessions.fold<int>(0, (sum, s) {
            final start = DateTime.parse(s['started_at']);
            final end   = DateTime.parse(s['ended_at']);
            return sum + end.difference(start).inMinutes;
          });

          // ----------  GRAPH DATA  ----------
          final Map<String, int> byDay = {};
          for (var s in sessions) {
            final key = _fmtShort.format(DateTime.parse(s['started_at']));
            byDay[key] = (byDay[key] ?? 0) + 1;
          }
          final chartData = byDay.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          // ----------  UI  ----------
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ------ LISTE & RÉSUMÉ  ------
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Résumé + date-picker
                      Material(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "$total sessions – $totalMin min",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              // Date from
                              _DateButton(
                                label: _fromDate == null ? 'Du...' : _fmtShort.format(_fromDate!),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _fromDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) setState(() => _fromDate = picked);
                                },
                              ),
                              const SizedBox(width: 8),
                              // Date to
                              _DateButton(
                                label: _toDate == null ? 'Au...' : _fmtShort.format(_toDate!),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _toDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) setState(() => _toDate = picked);
                                },
                              ),
                              IconButton(
                                tooltip: 'Réinitialiser dates',
                                onPressed: () => setState(() {
                                  _fromDate = null;
                                  _toDate = null;
                                }),
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Liste
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: ListView.separated(
                            key: ValueKey(sessions.hashCode),
                            itemCount: sessions.length,
                            separatorBuilder: (_, __) => const Divider(height: 0),
                            itemBuilder: (context, i) {
                              final s = sessions[i];
                              return ListTile(
                                leading: Icon(_iconFor(s['type'])),
                                title: Text(_labelFor(s['type'])),
                                subtitle: Text(
                                  'Début : ${_fmtLong.format(DateTime.parse(s['started_at']))}\n'
                                  'Fin   : ${_fmtLong.format(DateTime.parse(s['ended_at']))}',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // ------ GRAPHIQUE  ------
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Material(
                      key: ValueKey(chartData.hashCode),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final i = value.toInt();
                                    if (i >= 0 && i < chartData.length) {
                                      return Text(chartData[i].key, style: const TextStyle(fontSize: 10));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: chartData
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.value.toDouble(),
                                        width: 14,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------ UTILITAIRES UI ------------------
  Future<void> _exportCsv(TimerService timer) async {
    final data = await timer.fetchSessionHistory();
    final rows = [
      ['Type', 'Début', 'Fin'],
      ...data.map((s) => [s['type'], s['started_at'], s['ended_at']]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sessions_export.csv');
    await file.writeAsString(csv);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exporté : ${file.path}')),
      );
    }
  }

  Future<void> _confirmAndDelete(TimerService timer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Effacer toutes les sessions ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await timer.deleteAllSessions();
      if (context.mounted) setState(() {}); // refresh
    }
  }

  IconData _iconFor(String? t) => switch (t) {
        'focus'      => Icons.work,
        'shortBreak' => Icons.coffee,
        'longBreak'  => Icons.self_improvement,
        _            => Icons.help_outline,
      };

  String _labelFor(String? t) => switch (t) {
        'focus'      => 'Travail',
        'shortBreak' => 'Pause courte',
        'longBreak'  => 'Pause longue',
        _            => 'Inconnu',
      };
}

// Petit bouton Material 3 pour date picker
class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(label),
    );
  }
}
