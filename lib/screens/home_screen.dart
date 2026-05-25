import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../services/database_service.dart';
import '../widgets/progress_card.dart';
import '../widgets/food_list.dart';
import '../widgets/input_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyRecord? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final rec = await DatabaseService.getOrCreateToday();
    setState(() { _record = rec; _loading = false; });
  }

  Future<void> _updateField(String key, dynamic value) async {
    if (_record == null) return;
    final updated = _record!.copyWith(**{key: value});
    await DatabaseService.saveRecord(updated);
    setState(() => _record = updated);
  }

  void _addFood() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const FoodInputDialog(),
    );
    if (result != null) {
      await DatabaseService.addFoodEntry(FoodEntry(
        recordId: _record!.id!,
        name: result['name'],
        calories: (result['calories'] as num).toDouble(),
      ));
      _loadRecord();
    }
  }

  String _today() => DateFormat('yyyy年M月d日 E', 'zh_CN').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    final rec = _record!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('健康追踪', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(_today(), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
        actions: [
          if (rec.weight > 0 && rec.height > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'BMI ${rec.bmi.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadRecord, child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 三大指标卡片
          ProgressCard(
            icon: Icons.restaurant_outlined,
            label: '热量',
            value: '${rec.caloriesConsumed.round()}',
            unit: '千卡',
            goal: rec.caloriesGoal,
            color: const Color(0xFFE57373),
            onTapGoal: () async {
              final g = await _editGoal(rec.caloriesGoal, '每日热量目标 (千卡)');
              if (g != null) _updateField('caloriesGoal', g);
            },
          ),
          const SizedBox(height: 12),
          ProgressCard(
            icon: Icons.water_drop_outlined,
            label: '饮水',
            value: '${rec.waterIntake.round()}',
            unit: '毫升',
            goal: rec.waterGoal,
            color: const Color(0xFF64B5F6),
            onTapGoal: () async {
              final g = await _editGoal(rec.waterGoal, '每日饮水目标 (毫升)');
              if (g != null) _updateField('waterGoal', g);
            },
          ),
          const SizedBox(height: 12),
          ProgressCard(
            icon: Icons.directions_run,
            label: '运动',
            value: '${rec.exerciseMinutes}',
            unit: '分钟',
            goal: rec.exerciseGoal.toDouble(),
            color: const Color(0xFF81C784),
            onTapGoal: () async {
              final g = await _editGoal(rec.exerciseGoal.toDouble(), '每日运动目标 (分钟)');
              if (g != null) _updateField('exerciseGoal', g.round());
            },
          ),

          const SizedBox(height: 20),
          // 快捷调整区
          _buildQuickAdjust(rec),
          const SizedBox(height: 20),
          // 饮食记录
          FoodListSection(
            recordId: rec.id!,
            onDeleted: _loadRecord,
            onAddFood: _addFood,
          ),
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFood,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAdjust(DailyRecord rec) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('快捷调整', style: Theme.of(context).textTheme.titleSmall),
      ),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _quickChip(Icons.water_drop_outlined, '+100ml', () {
          _updateField('waterIntake', rec.waterIntake + 100);
        }),
        _quickChip(Icons.water_drop_outlined, '+250ml', () {
          _updateField('waterIntake', rec.waterIntake + 250);
        }),
        _quickChip(Icons.directions_run, '+15分钟', () {
          _updateField('exerciseMinutes', rec.exerciseMinutes + 15);
        }),
        _quickChip(Icons.directions_run, '+30分钟', () {
          _updateField('exerciseMinutes', rec.exerciseMinutes + 30);
        }),
      ]),
    ]);
  }

  Widget _quickChip(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }

  Future<double?> _editGoal(double current, String title) async {
    final controller = TextEditingController(text: current.round().toString());
    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () {
            final v = double.tryParse(controller.text);
            Navigator.pop(context, v);
          }, child: const Text('确定')),
        ],
      ),
    );
  }
}