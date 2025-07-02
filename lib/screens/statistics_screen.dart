import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    final timerService = Provider.of<TimerService>(context, listen: false);
    _sessionsFuture = timerService.fetchSessionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune session enregistrée"));
          }

          final sessions = snapshot.data!;
          // Regroupe les sessions par date
          final Map<DateTime, List<Map<String, dynamic>>> events = {};
          for (var s in sessions) {
            final date = DateUtils.dateOnly(DateTime.parse(s['ended_at']));
            events.putIfAbsent(date, () => []).add(s);
          }

          // Calcul pour le graphique
          final Map<int, int> dailyCounts = {};
          for (var entry in events.entries) {
            final day = entry.key.difference(DateTime(1970)).inDays;
            dailyCounts[day] = entry.value.length;
          }

          return _buildCalendarAndChart(events, dailyCounts, sessions);
        },
      ),
    );
  }

  Widget _buildCalendarAndChart(Map<DateTime, List<Map<String, dynamic>>> events, Map<int, int> dailyCounts, List<Map<String, dynamic>> sessions) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Exporter l\'historique (CSV)'),
          onPressed: () async {
            final csv = const ListToCsvConverter().convert([
              ['start', 'end', 'isFocus'],
              ...sessions.map((s) => [
                    s['start'].toString(),
                    s['end'].toString(),
                    s['isFocus'],
                  ]),
            ]);
            final dir = await FilePicker.platform.getDirectoryPath();
            if (dir != null) {
              final file = File('$dir/pomodoro_history.csv');
              await file.writeAsString(csv);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export CSV terminé !')),
                );
              }
            }
          },
        ),
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: DateTime.now(),
          eventLoader: (day) => events[day] ?? [],
          calendarBuilders: CalendarBuilders(
            markerBuilder: (ctx, date, events) => events.isNotEmpty
                ? Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${events.length}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: dailyCounts.entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                      .toList(),
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
  
