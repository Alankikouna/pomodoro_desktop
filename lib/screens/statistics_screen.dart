import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/timer_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques")),
      body: const StatisticsContent(),
    );
  }
}

class StatisticsContent extends StatefulWidget {
  const StatisticsContent({super.key});

  @override
  State<StatisticsContent> createState() => _StatisticsContentState();
}

class _StatisticsContentState extends State<StatisticsContent> {
  late Future<List<Map<String, dynamic>>> _futureSessions;

  @override
  void initState() {
    super.initState();
    _futureSessions = Provider.of<TimerService>(context, listen: false).fetchSessionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureSessions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data!;
        final focusSessions = sessions.where((s) => s['type'] == 'focus');
        final totalFocusMinutes = focusSessions.fold<int>(0, (sum, s) {
          final start = DateTime.parse(s['started_at']);
          final end = DateTime.parse(s['ended_at']);
          return sum + end.difference(start).inMinutes;
        });
        final Map<String, int> focusPerDay = {};
        for (final s in focusSessions) {
          final day = DateTime.parse(s['started_at']).toIso8601String().substring(0, 10);
          final start = DateTime.parse(s['started_at']);
          final end = DateTime.parse(s['ended_at']);
          focusPerDay[day] = (focusPerDay[day] ?? 0) + end.difference(start).inMinutes;
        }
        final bestDay = (focusPerDay.entries.isEmpty)
            ? null
            : focusPerDay.entries.reduce((a, b) => a.value > b.value ? a : b);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("Nombre total de sessions : ${sessions.length}", style: Theme.of(context).textTheme.titleLarge),
            Text("Temps total de focus : $totalFocusMinutes min", style: Theme.of(context).textTheme.bodyLarge),
            if (bestDay != null)
              Text("Meilleur jour : ${bestDay.key} (${bestDay.value} min)", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            if (focusPerDay.isNotEmpty) ...[
              Text("Focus par jour", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (focusPerDay.values.isEmpty ? 60 : focusPerDay.values.reduce((a, b) => a > b ? a : b).toDouble() + 10),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final keys = focusPerDay.keys.toList();
                            if (value.toInt() < 0 || value.toInt() >= keys.length) return const SizedBox();
                            final label = keys[value.toInt()].substring(5); // MM-DD
                            return Text(label, style: const TextStyle(fontSize: 10));
                          },
                          reservedSize: 32,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(focusPerDay.length, (i) {
                      final value = focusPerDay.values.elementAt(i).toDouble();
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: Colors.indigo,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
            if (focusPerDay.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text("Progression hebdomadaire", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: (focusPerDay.values.isEmpty ? 60 : focusPerDay.values.reduce((a, b) => a > b ? a : b).toDouble() + 10),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final keys = focusPerDay.keys.toList();
                            if (value.toInt() < 0 || value.toInt() >= keys.length) return const SizedBox();
                            final label = keys[value.toInt()].substring(5); // MM-DD
                            return Text(label, style: const TextStyle(fontSize: 10));
                          },
                          reservedSize: 32,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(focusPerDay.length, (i) {
                          final value = focusPerDay.values.elementAt(i).toDouble();
                          return FlSpot(i.toDouble(), value);
                        }),
                        isCurved: true,
                        color: Colors.indigo,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text("Badges & Succès", style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (totalFocusMinutes >= 120)
                  Chip(
                    avatar: const Icon(Icons.emoji_events, color: Colors.amber),
                    label: const Text("2h de focus cumulées"),
                    backgroundColor: Colors.amber.shade50,
                  ),
                if (focusSessions.length >= 10)
                  Chip(
                    avatar: const Icon(Icons.star, color: Colors.blue),
                    label: const Text("10 sessions de focus"),
                    backgroundColor: Colors.blue.shade50,
                  ),
                if (bestDay != null && bestDay.value >= 60)
                  Chip(
                    avatar: const Icon(Icons.local_fire_department, color: Colors.red),
                    label: Text("🔥 ${bestDay.value} min en un jour"),
                    backgroundColor: Colors.red.shade50,
                  ),
                // Ajoute d'autres badges selon tes critères
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Exporter l'historique (CSV)"),
              onPressed: () async {
                final csv = StringBuffer('type,started_at,ended_at\n');
                for (final s in sessions) {
                  csv.writeln('${s['type']},${s['started_at']},${s['ended_at']}');
                }
                // Utilise le répertoire Documents de l'utilisateur
                final directory = await getApplicationDocumentsDirectory();
                final file = File('${directory.path}/pomodoro_sessions.csv');
                await file.writeAsString(csv.toString());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Exporté dans ${file.path}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}