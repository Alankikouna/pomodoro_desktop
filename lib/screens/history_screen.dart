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
  final _filters = {
    'all': 'Tous',
    'focus': 'Travail',
    'shortBreak': 'Pause courte',
    'longBreak': 'Pause longue',
  };

  @override
  Widget build(BuildContext context) {
    final timerService = context.read<TimerService>();
    final fmt = DateFormat('dd/MM/yyyy – HH:mm');
    final shortFmt = DateFormat('dd/MM');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter en CSV',
            onPressed: () async {
              final data = await timerService.fetchSessionHistory();
              final rows = [
                ['Type', 'Début', 'Fin'],
                ...data.map((s) => [
                      s['type'],
                      s['started_at'],
                      s['ended_at'],
                    ]),
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
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value!),
              items: _filters.entries
                  .map((entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: timerService.fetchSessionHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text("Erreur : ${snapshot.error}"));
            return const Center(child: CircularProgressIndicator());
          }

          final allSessions = snapshot.data!;
          final filtered = _selectedFilter == 'all'
              ? allSessions
              : allSessions.where((s) => s['type'] == _selectedFilter).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('Aucune session trouvée.'));
          }

          // Résumé
          final total = filtered.length;
          final totalMinutes = filtered.fold<int>(0, (sum, s) {
            final start = DateTime.tryParse(s['started_at'] ?? '') ?? DateTime(0);
            final end = DateTime.tryParse(s['ended_at'] ?? '') ?? DateTime(0);
            return sum + end.difference(start).inMinutes;
          });

          // Données pour fl_chart
          final Map<String, int> sessionsByDay = {};
          for (var s in filtered) {
            final date = DateTime.tryParse(s['started_at'] ?? '');
            if (date != null) {
              final key = shortFmt.format(date);
              sessionsByDay[key] = (sessionsByDay[key] ?? 0) + 1;
            }
          }

          final chartData = sessionsByDay.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return Row(
            children: [
              // Liste
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "$total sessions – $totalMinutes minutes",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final type = s['type'];
                          final started = DateTime.tryParse(s['started_at'] ?? '') ?? DateTime(0);
                          final ended = DateTime.tryParse(s['ended_at'] ?? '') ?? DateTime(0);
                          return ListTile(
                            leading: Icon(_iconFor(type)),
                            title: Text(_labelFor(type)),
                            subtitle: Text(
                              "Début : ${fmt.format(started)}\nFin : ${fmt.format(ended)}",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Graphique
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                        ),
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
                                BarChartRodData(toY: e.value.value.toDouble(), width: 14),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'focus' => Icons.work,
        'shortBreak' => Icons.coffee,
        'longBreak' => Icons.self_improvement,
        _ => Icons.help_outline,
      };

  String _labelFor(String type) => switch (type) {
        'focus' => 'Travail',
        'shortBreak' => 'Pause courte',
        'longBreak' => 'Pause longue',
        _ => 'Inconnu',
      };
}
