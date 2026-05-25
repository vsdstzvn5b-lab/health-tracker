import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _height = 0;
  double _weight = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _height = prefs.getDouble('user_height') ?? 0;
      _weight = prefs.getDouble('user_weight') ?? 0;
    });
  }

  Future<void> _saveHeight(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_height', v);
    final today = await DatabaseService.getOrCreateToday({'height': v});
    setState(() => _height = v);
  }

  Future<void> _saveWeight(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', v);
    final today = await DatabaseService.getOrCreateToday({'weight': v});
    setState(() => _weight = v);
  }

  double get _bmi => _height > 0 && _weight > 0
    ? _weight / ((_height / 100) * (_height / 100)) : 0;

  String get _bmiLabel {
    if (_bmi <= 0) return '—';
    if (_bmi < 18.5) return '偏瘦';
    if (_bmi < 24) return '正常';
    if (_bmi < 28) return '偏胖';
    return '肥胖';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // BMI 展示卡片
        if (_height > 0 && _weight > 0)
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('您的 BMI', style: TextStyle(
                  fontSize: 14, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                )),
                const SizedBox(height: 4),
                Text(_bmi.toStringAsFixed(1), style: TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                )),
                Text(_bmiLabel, style: TextStyle(
                  fontSize: 16, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                )),
              ]),
            ),
          ),
        const SizedBox(height: 16),

        // 身体数据设置
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.height),
              title: const Text('身高'),
              trailing: Text(
                _height > 0 ? '${_height.round()} cm' : '未设置',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              onTap: () => _showInput('身高 (cm)', _height, _saveHeight),
            ),
            Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.outline.withOpacity(0.2)),
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: const Text('体重'),
              trailing: Text(
                _weight > 0 ? '${_weight.round()} kg' : '未设置',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              onTap: () => _showInput('体重 (kg)', _weight, _saveWeight),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // 目标设置
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            _buildGoalTile('每日热量目标', 'caloriesGoal', '2000', '千卡', Icons.restaurant_outlined, theme),
            Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildGoalTile('每日饮水目标', 'waterGoal', '2000', '毫升', Icons.water_drop_outlined, theme),
            Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildGoalTile('每日运动目标', 'exerciseGoal', '60', '分钟', Icons.directions_run, theme),
          ]),
        ),

        const SizedBox(height: 24),

        // 说明
        Text(
          '• 热量计算基于摄入估算，仅供参考\n'
          '• BMI 公式：体重kg ÷ 身高m²\n'
          '• 建议在每日同一时间测量体重',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline, height: 1.8,
          ),
        ),
      ]),
    );
  }

  Widget _buildGoalTile(String title, String key, String defaultVal, String unit, IconData icon, ThemeData theme) {
    return FutureBuilder(
      future: DatabaseService.getOrCreateToday(),
      builder: (context, snap) {
        double val = 0;
        if (snap.hasData) {
          switch (key) {
            case 'caloriesGoal':  val = snap.data!.caloriesGoal; break;
            case 'waterGoal':     val = snap.data!.waterGoal;    break;
            case 'exerciseGoal':  val = snap.data!.exerciseGoal.toDouble(); break;
          }
        }
        return ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Text(
            val > 0 ? '${val.round()} $unit' : '未设置',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
          onTap: () async {
            final controller = TextEditingController(text: val > 0 ? val.round().toString() : defaultVal);
            final result = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('设置 $title'),
                content: TextField(
                  controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixText: unit,
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('确定')),
                ],
              ),
            );
            if (result != null) {
              final v = double.tryParse(result);
              if (v != null) {
                final today = await DatabaseService.getOrCreateToday({key: v});
                final updated = today.copyWith(**{key: v});
                await DatabaseService.saveRecord(updated);
                setState(() {});
              }
            }
          },
        );
      },
    );
  }

  Future<void> _showInput(String label, double current, Future<void> Function(double) onSave) async {
    final controller = TextEditingController(
      text: current > 0 ? current.round().toString() : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('确定')),
        ],
      ),
    );
    if (result != null) {
      final v = double.tryParse(result);
      if (v != null) await onSave(v);
    }
  }
}