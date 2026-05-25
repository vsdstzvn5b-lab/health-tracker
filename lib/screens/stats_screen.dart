import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../services/database_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<DailyRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recs = await DatabaseService.getRecentRecords(14);
    setState(() { _records = recs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('数据统计', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _records.isEmpty
        ? const Center(child: Text('暂无数据'))
        : RefreshIndicator(onRefresh: _load, child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard('热量趋势', _buildCaloriesChart(), theme),
              const SizedBox(height: 16),
              _buildCard('饮水趋势', _buildWaterChart(), theme),
              const SizedBox(height: 16),
              _buildCard('运动趋势', _buildExerciseChart(), theme),
              const SizedBox(height: 16),
              _buildWeeklySummary(theme),
            ],
          )),
    );
  }

  Widget _buildCard(String title, Widget chart, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(height: 160, child: chart),
        ]),
      ),
    );
  }

  Widget _buildCaloriesChart() {
    final data = _records.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].caloriesConsumed));
    }
    return spots.length < 2
      ? const Center(child: Text('数据不足'))
      : LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFE57373),
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFE57373).withOpacity(0.1),
              ),
            )],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                  '${s.y.round()} 千卡', const TextStyle(color: Colors.white, fontSize: 12),
                )).toList(),
              ),
            ),
          ),
        );
  }

  Widget _buildWaterChart() {
    final data = _records.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].waterIntake));
    }
    return spots.length < 2
      ? const Center(child: Text('数据不足'))
      : BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: spots.asMap().entries.map((e) => BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(
                toY: e.value.y,
                color: const Color(0xFF64B5F6),
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )],
            )).toList(),
          ),
        );
  }

  Widget _buildExerciseChart() {
    final data = _records.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].exerciseMinutes.toDouble()));
    }
    return spots.length < 2
      ? const Center(child: Text('数据不足'))
      : LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF81C784),
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF81C784).withOpacity(0.1),
              ),
            )],
          ),
        );
  }

  Widget _buildWeeklySummary(ThemeData theme) {
    final recent7 = _records.take(7).toList();
    if (recent7.isEmpty) return const SizedBox.shrink();

    double avgCal = recent7.map((r) => r.caloriesConsumed).reduce((a, b) => a + b) / recent7.length;
    double avgWater = recent7.map((r) => r.waterIntake).reduce((a, b) => a + b) / recent7.length;
    double avgExercise = recent7.map((r) => r.exerciseMinutes).reduce((a, b) => a + b) / recent7.length;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('近7日平均', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _avgItem('热量', '${avgCal.round()}', '千卡', const Color(0xFFE57373), theme),
            _avgItem('饮水', '${avgWater.round()}', '毫升', const Color(0xFF64B5F6), theme),
            _avgItem('运动', '${avgExercise.round()}', '分钟', const Color(0xFF81C784), theme),
          ]),
        ]),
      ),
    );
  }

  Widget _avgItem(String label, String value, String unit, Color color, ThemeData theme) {
    return Expanded(child: Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(unit, style: theme.textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(label, style: theme.textTheme.bodySmall),
    ]));
  }
}