import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/database_service.dart';

class FoodListSection extends StatefulWidget {
  final int recordId;
  final VoidCallback onDeleted;
  final VoidCallback onAddFood;

  const FoodListSection({
    super.key,
    required this.recordId,
    required this.onDeleted,
    required this.onAddFood,
  });

  @override
  State<FoodListSection> createState() => _FoodListSectionState();
}

class _FoodListSectionState extends State<FoodListSection> {
  List<FoodEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseService.getFoodEntries(widget.recordId);
    setState(() { _entries = entries; _loading = false; });
  }

  Future<void> _delete(FoodEntry entry) async {
    await DatabaseService.deleteFoodEntry(entry.id!, widget.recordId);
    widget.onDeleted();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('饮食记录', style: theme.textTheme.titleSmall),
        const Spacer(),
        TextButton.icon(
          onPressed: widget.onAddFood,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('添加'),
        ),
      ]),
      const SizedBox(height: 8),
      if (_loading)
        const Center(child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ))
      else if (_entries.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Icon(Icons.restaurant_outlined, size: 32, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text('暂无饮食记录\n点击下方 + 添加', textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ]),
        )
      else
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _entries.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, indent: 16, endIndent: 16,
              color: theme.colorScheme.outline.withOpacity(0.15),
            ),
            itemBuilder: (ctx, i) => Dismissible(
              key: Key('food_${_entries[i].id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _delete(_entries[i]),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant_outlined,
                    color: Color(0xFFE57373), size: 16),
                ),
                title: Text(_entries[i].name, style: const TextStyle(fontSize: 14)),
                trailing: Text(
                  '${_entries[i].calories.round()} 千卡',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: const Color(0xFFE57373),
                  ),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}