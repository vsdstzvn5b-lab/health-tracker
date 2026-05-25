import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final double goal;
  final Color color;
  final VoidCallback? onTapGoal;

  const ProgressCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.goal,
    required this.color,
    this.onTapGoal,
  });

  double get percent => goal > 0
    ? (double.tryParse(value.replaceAll(',', '')) ?? 0) / goal
    : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = double.tryParse(value.replaceAll(',', '')) ?? 0;
    final pct = goal > 0 ? (displayValue / goal).clamp(0.0, 1.0) : 0.0;
    final isOver = displayValue > goal;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: theme.textTheme.titleSmall),
            const Spacer(),
            if (onTapGoal != null)
              InkWell(
                onTap: onTapGoal,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      '${goal.round()} $unit',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_outlined, size: 12, color: theme.colorScheme.outline),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold,
                color: isOver ? color : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(unit, style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              )),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(isOver
                ? const Color(0xFFFF9800)
                : color),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isOver ? '超标 ${(displayValue - goal).round()} $unit' : '完成 ${(pct * 100).round()}%',
              style: TextStyle(fontSize: 11, color: isOver ? const Color(0xFFFF9800) : theme.colorScheme.outline),
            ),
          ),
        ]),
      ),
    );
  }
}