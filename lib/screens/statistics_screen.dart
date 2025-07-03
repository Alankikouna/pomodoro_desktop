import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // pour formater la date la plus productive

import '../services/timer_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;
  String _selectedPeriod = '7';
  bool _showLineChart = true;

  @override
  void initState() {
    super.initState();
    final timerService = provider.Provider.of<TimerService>(context, listen: false);
    _sessionsFuture = timerService.fetchSessionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: '7', child: Text('7j')),
              DropdownMenuItem(value: '30', child: Text('30j')),
              DropdownMenuItem(value: '90', child: Text('90j')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(_showLineChart ? Icons.bar_chart : Icons.show_chart),
            onPressed: () {
              setState(() {
                _showLineChart = !_showLineChart;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune session enregistrée'));
          }

          final sessions = snapshot.data!;
          final durationsByType = _computeDurationsByType(sessions);
          final filteredDurations = _filterByPeriod(durationsByType);
          final totalFocusMinutes = _calculateTotalFocus(filteredDurations);
          final totalSessions = sessions.length;
          final averageDuration = totalSessions == 0 ? 0 : (totalFocusMinutes / totalSessions);
          final mostProductive = _findMostProductiveDay(sessions);

          return Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Total focus: $totalFocusMinutes min',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _showLineChart
                    ? _buildLineChart(filteredDurations)
                    : _buildBarChart(filteredDurations),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 Statistiques globales',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text('• Total de sessions : $totalSessions'),
                        Text('• Total focus : $totalFocusMinutes min'),
                        Text('• Durée moyenne : ${averageDuration.toStringAsFixed(1)} min'),
                        if (mostProductive != null)
                          Text(
                            '• Jour le plus productif : '
                            '${DateFormat.yMMMd().format(mostProductive.date)} '
                            '(${mostProductive.count} sessions)',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExportButton(sessions),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  /* ─────── DATA PROCESSING ─────── */

  Map<String, Map<DateTime, int>> _computeDurationsByType(List<Map<String, dynamic>> sessions) {
    final Map<String, Map<DateTime, int>> out = {
      'focus': {},
      'short_break': {},
      'long_break': {},
    };

    for (var s in sessions) {
      final type = s['type'];
      if (!out.containsKey(type)) continue;

      final start = DateTime.parse(s['started_at']);
      final end = DateTime.parse(s['ended_at']);
      final minutes = end.difference(start).inMinutes;
      final date = DateTime(start.year, start.month, start.day);

      out[type]!.update(date, (v) => v + minutes, ifAbsent: () => minutes);
    }

    return out;
  }

  Map<String, Map<DateTime, int>> _filterByPeriod(Map<String, Map<DateTime, int>> durations) {
    final days = int.parse(_selectedPeriod);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final result = <String, Map<DateTime, int>>{};

    durations.forEach((type, map) {
      result[type] = {
        for (var entry in map.entries)
          if (entry.key.isAfter(cutoff)) entry.key: entry.value,
      };
    });

    return result;
  }

  int _calculateTotalFocus(Map<String, Map<DateTime, int>> durations) {
    return durations['focus']?.values.fold<int>(0, (a, b) => (a ?? 0) + (b ?? 0)) ?? 0;
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupSessionsByDate(List<Map<String, dynamic>> sessions) {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var s in sessions) {
      final d = DateUtils.dateOnly(DateTime.parse(s['ended_at']));
      events.putIfAbsent(d, () => []).add(s);
    }
    return events;
  }

  /* ─────── UI GRAPH ─────── */

  Widget _buildLineChart(Map<String, Map<DateTime, int>> durations) {
    final allDates = durations.values.expand((m) => m.keys).toSet().toList()..sort();
    final typeColors = {
      'focus': Colors.green,
      'short_break': Colors.orange,
      'long_break': Colors.blueGrey,
    };

    final lines = durations.entries.map((entry) {
      final spots = <FlSpot>[];
      for (int i = 0; i < allDates.length; i++) {
        final d = allDates[i];
        spots.add(FlSpot(i.toDouble(), (entry.value[d] ?? 0).toDouble()));
      }

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: typeColors[entry.key],
        barWidth: 3,
        dotData: FlDotData(show: true),
      );
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: lines,
        minY: 0,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= allDates.length) return const SizedBox();
                final d = allDates[i];
                return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, Map<DateTime, int>> durations) {
    final dates = durations['focus']?.keys.toList() ?? [];
    dates.sort();

    final bars = dates.asMap().entries.map((entry) {
      final i = entry.key;
      final date = entry.value;
      final value = durations['focus']![date]!.toDouble();

      return BarChartRodData(toY: value, width: 12, color: Colors.green);
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: List.generate(bars.length, (i) {
          return BarChartGroupData(x: i, barRods: [bars[i]]);
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dates.length) return const SizedBox();
                final d = dates[idx];
                return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
        ),
      ),
    );
  }

  /* ─────── EXPORT ─────── */

  Widget _buildExportButton(List<Map<String, dynamic>> sessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text('Exporter CSV'),
        onPressed: () async {
          final csv = const ListToCsvConverter().convert([
            ['Type', 'Début', 'Fin', 'Durée (min)'],
            ...sessions.map((s) {
              final start = DateTime.parse(s['started_at']);
              final end = DateTime.parse(s['ended_at']);
              return [
                s['type'],
                start.toIso8601String(),
                end.toIso8601String(),
                end.difference(start).inMinutes
              ];
            }),
          ]);
          final dir = await FilePicker.platform.getDirectoryPath();
          if (dir != null) {
            final file = File('$dir/pomodoro_history.csv');
            await file.writeAsString(csv);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export CSV terminé !')),
              );
            }
          }
        },
      ),
    );
  }
}

class _MostProductiveDay {
  final DateTime date;
  final int count;
  _MostProductiveDay(this.date, this.count);
}

_MostProductiveDay? _findMostProductiveDay(List<Map<String, dynamic>> sessions) {
  final Map<DateTime, int> counter = {};
  for (var s in sessions) {
    final d = DateUtils.dateOnly(DateTime.parse(s['ended_at']));
    counter.update(d, (v) => v + 1, ifAbsent: () => 1);
  }
  if (counter.isEmpty) return null;
  final top = counter.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return _MostProductiveDay(top.key, top.value);
}
