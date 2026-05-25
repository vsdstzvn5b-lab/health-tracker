import 'package:flutter/material.dart';

/// 食物输入对话框
/// 用户输入食物名称和热量，自动记录到今日饮食
class FoodInputDialog extends StatefulWidget {
  const FoodInputDialog({super.key});

  @override
  State<FoodInputDialog> createState() => _FoodInputDialogState();
}

class _FoodInputDialogState extends State<FoodInputDialog> {
  final _nameController = TextEditingController();
  final _calController  = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 常见食物热量参考 (千卡/100g)
  static const _quickItems = [
    ('米饭', 130),
    ('面条', 280),
    ('馒头', 220),
    ('鸡蛋', 140),
    ('鸡胸肉', 130),
    ('牛肉', 250),
    ('苹果', 50),
    ('香蕉', 90),
    ('牛奶', 65),
    ('酸奶', 70),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    super.dispose();
  }

  void _selectQuick(String name, int cal) {
    _nameController.text = name;
    _calController.text = cal.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('添加饮食'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('快捷添加', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _quickItems.map((item) {
                final selected = _nameController.text == item.$1;
                return InkWell(
                  onTap: () => _selectQuick(item.$1, item.$2),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '食物名称', border: OutlineInputBorder(),
                hintText: '如：鸡胸肉沙拉',
              ),
              validator: (v) => v == null || v.isEmpty ? '请输入食物名称' : null,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _calController,
              decoration: const InputDecoration(
                labelText: '热量', border: OutlineInputBorder(),
                hintText: '千卡', suffixText: '千卡',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入热量';
                if (double.tryParse(v) == null) return '请输入有效数字';
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _submit, child: const Text('添加')),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'calories': double.parse(_calController.text),
      });
    }
  }
}