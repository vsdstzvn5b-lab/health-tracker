import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HealthTrackerApp(),
    ),
  );
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '健康追踪',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/diet',
      builder: (context, state) => const DietPage(),
    ),
    GoRoute(
      path: '/water',
      builder: (context, state) => const WaterPage(),
    ),
    GoRoute(
      path: '/exercise',
      builder: (context, state) => const ExercisePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);

// ==================== 数据模型 ====================

class DietRecord {
  final String foodName;
  final int calories;
  final String mealType;
  final String time;

  DietRecord({
    required this.foodName,
    required this.calories,
    required this.mealType,
    required this.time,
  });
}

class WaterRecord {
  final int amount;
  final String time;

  WaterRecord({
    required this.amount,
    required this.time,
  });

  String get formattedAmount {
    if (amount < 1000) {
      return '${amount}ml';
    } else {
      final liters = amount / 1000.0;
      return '${liters.toStringAsFixed(liters.truncateToDouble() == liters ? 0 : 1)}L';
    }
  }
}

class ExerciseRecord {
  final String type;
  final int duration;
  final int caloriesBurned;
  final String time;

  ExerciseRecord({
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.time,
  });
}

// ==================== 首页 ====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<DietRecord> _dietRecords = [
    DietRecord(foodName: '全麦面包', calories: 247, mealType: '早餐', time: '08:30'),
    DietRecord(foodName: '鸡胸肉沙拉', calories: 320, mealType: '午餐', time: '12:15'),
    DietRecord(foodName: '苹果', calories: 95, mealType: '加餐', time: '15:30'),
  ];

  final List<WaterRecord> _waterRecords = [
    WaterRecord(amount: 300, time: '09:00'),
    WaterRecord(amount: 500, time: '11:30'),
    WaterRecord(amount: 400, time: '14:00'),
  ];

  final List<ExerciseRecord> _exerciseRecords = [
    ExerciseRecord(type: '跑步', duration: 25, caloriesBurned: 250, time: '18:00'),
  ];

  int get _todayCalories => _dietRecords.fold(0, (sum, r) => sum + r.calories);
  int get _todayWater => _waterRecords.fold(0, (sum, r) => sum + r.amount);
  int get _todayExercise => _exerciseRecords.fold(0, (sum, r) => sum + r.duration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日概览'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const DietPage(),
          const WaterPage(),
          const ExercisePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: '饮食',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            activeIcon: Icon(Icons.water_drop),
            label: '饮水',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run_outlined),
            activeIcon: Icon(Icons.directions_run),
            label: '运动',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎卡片
          Card(
            color: const Color(0xFF4CAF50),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '你好，用户！',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '今天也要保持健康哦！',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.wb_sunny, size: 48, color: Colors.yellow[300]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 进度圆环
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('今日进度',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressRing('饮食', _todayCalories / 2000,
                          '$_todayCalories/2000', '千卡', const Color(0xFFFF5722)),
                      _buildProgressRing('饮水', _todayWater / 2000,
                          _waterRecords.isNotEmpty ? _waterRecords[0].formattedAmount : '0ml', '毫升', const Color(0xFF00BCD4)),
                      _buildProgressRing('运动', _todayExercise / 30,
                          '$_todayExercise/30', '分钟', const Color(0xFF9C27B0)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 快捷操作
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(Icons.restaurant, '记录饮食', const Color(0xFFFF5722), 0),
              _buildQuickAction(Icons.water_drop, '记录饮水', const Color(0xFF00BCD4), 1),
              _buildQuickAction(Icons.directions_run, '记录运动', const Color(0xFF9C27B0), 2),
              _buildQuickAction(Icons.scale, '记录体重', const Color(0xFF795548), 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(String label, double percent, String value, String unit, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 8.0,
          percent: percent.clamp(0.0, 1.0),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18),
              ),
            ],
          ),
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: color.withOpacity(0.1),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index + 1;
        });
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ==================== 饮食页面 ====================

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<DietRecord> _records = [
    DietRecord(foodName: '全麦面包', calories: 247, mealType: '早餐', time: '08:30'),
    DietRecord(foodName: '鸡胸肉沙拉', calories: 320, mealType: '午餐', time: '12:15'),
    DietRecord(foodName: '苹果', calories: 95, mealType: '加餐', time: '15:30'),
    DietRecord(foodName: '白米饭', calories: 174, mealType: '晚餐', time: '18:30'),
  ];

  @override
  Widget build(BuildContext context) {
    final totalCalories = _records.fold(0, (sum, r) => sum + r.calories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('饮食记录'),
      ),
      body: Column(
        children: [
          // 热量概览
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFF5722).withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalorieItem('已摄入', '$totalCalories', '千卡', const Color(0xFFFF5722)),
                Container(height: 40, width: 1, color: Colors.grey[300]!),
                _buildCalorieItem('目标', '2000', '千卡', Colors.grey[600]!),
                Container(height: 40, width: 1, color: Colors.grey[300]!),
                _buildCalorieItem('剩余', '${2000 - totalCalories}', '千卡',
                    (2000 - totalCalories) > 0 ? Colors.green : Colors.red),
              ],
            ),
          ),

          // 记录列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fastfood, color: Color(0xFFFF5722)),
                    ),
                    title: Text(record.foodName),
                    subtitle: Text('${record.mealType} ${record.time}'),
                    trailing: Text(
                      '${record.calories} 千卡',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('演示版：添加功能开发中')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalorieItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== 饮水页面 ====================

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final List<WaterRecord> _records = [
    WaterRecord(amount: 300, time: '09:00'),
    WaterRecord(amount: 500, time: '11:30'),
    WaterRecord(amount: 400, time: '14:00'),
    WaterRecord(amount: 300, time: '16:30'),
    WaterRecord(amount: 500, time: '19:00'),
  ];

  @override
  Widget build(BuildContext context) {
    final totalWater = _records.fold(0, (sum, r) => sum + r.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('饮水记录'),
      ),
      body: Column(
        children: [
          // 饮水概览
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF00BCD4).withOpacity(0.1),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: totalWater / 2000,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00BCD4)),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${(totalWater / 2000 * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00BCD4),
                          ),
                        ),
                        const Text('已完成', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _records.add(WaterRecord(
                            amount: 200,
                            time: '${DateTime.now().hour}:${DateTime.now().minute}',
                          ));
                        });
                      },
                      icon: const Icon(Icons.water_drop, size: 16),
                      label: const Text('200ml'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                        foregroundColor: Color(0xFF00BCD4),
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _records.add(WaterRecord(
                            amount: 500,
                            time: '${DateTime.now().hour}:${DateTime.now().minute}',
                          ));
                        });
                      },
                      icon: const Icon(Icons.water_drop, size: 16),
                      label: const Text('500ml'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                        foregroundColor: Color(0xFF00BCD4),
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _records.add(WaterRecord(
                            amount: 1000,
                            time: '${DateTime.now().hour}:${DateTime.now().minute}',
                          ));
                        });
                      },
                      icon: const Icon(Icons.water_drop, size: 16),
                      label: const Text('1L'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                        foregroundColor: Color(0xFF00BCD4),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 饮水记录列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water_drop, color: Color(0xFF00BCD4)),
                    ),
                    title: Text(record.formattedAmount),
                    trailing: Text(
                      record.time,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('添加饮水记录'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '饮水量（毫升）',
                    hintText: '例如：200',
                    suffixText: '毫升',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      final amount = int.tryParse(controller.text);
                      if (amount != null && amount > 0) {
                        setState(() {
                          _records.add(WaterRecord(
                            amount: amount,
                            time: '${DateTime.now().hour}:${DateTime.now().minute}',
                          ));
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('记录添加成功')),
                        );
                      }
                    },
                    child: const Text('保存'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== 运动页面 ====================

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final List<ExerciseRecord> _records = [
    ExerciseRecord(type: '跑步', duration: 25, caloriesBurned: 250, time: '18:00'),
  ];

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _records.fold(0, (sum, r) => sum + r.duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('运动记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('同步功能开发中')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 运动概览
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildExerciseStat(Icons.timer, '运动时长', '$totalMinutes', '分钟', context),
                Container(height: 40, width: 1, color: Colors.grey[300]!),
                _buildExerciseStat(Icons.trending_up, '目标完成', '${(totalMinutes / 30 * 100).toInt()}%', '', context),
                Container(height: 40, width: 1, color: Colors.grey[300]!),
                _buildExerciseStat(Icons.local_fire_department, '消耗热量', '--', '千卡', context),
              ],
            ),
          ),

          // 运动记录列表
          Expanded(
            child: _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '今天还没有运动记录',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击 + 添加，或点击同步按钮从健康APP导入',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.directions_run, color: Color(0xFF9C27B0)),
                          ),
                          title: Text(record.type),
                          subtitle: Text('${record.duration}分钟'),
                          trailing: Text(
                            '${record.caloriesBurned} 千卡',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('演示版：添加功能开发中')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExerciseStat(IconData icon, String label, String value, String unit, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF9C27B0), size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: '\n$unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ==================== 个人中心页面 ====================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'user@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 健康数据
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '健康数据',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.height, color: Color(0xFF4CAF50), size: 20),
                    ),
                    title: const Text('身高'),
                    trailing: const Text('175 cm'),
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(0xFF795548).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.monitor_weight, color: Color(0xFF795548), size: 20),
                    ),
                    title: const Text('当前体重'),
                    trailing: const Text('70 kg'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 功能菜单
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Color(0xFF4CAF50)),
                  title: const Text('数据统计'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('功能开发中')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Color(0xFF9C27B0)),
                  title: const Text('成就系统'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('功能开发中')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: Color(0xFF00BCD4)),
                  title: const Text('同步健康数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('功能开发中')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
