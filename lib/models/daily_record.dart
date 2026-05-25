/// 每日记录数据模型
class DailyRecord {
  final int? id;
  final DateTime date;
  final double caloriesConsumed; // 千卡
  final double caloriesGoal;      // 目标千卡
  final double waterIntake;       // 饮水量(ml)
  final double waterGoal;         // 饮水目标(ml)
  final int exerciseMinutes;      // 运动时长(分钟)
  final int exerciseGoal;         // 运动目标(分钟)
  final double weight;            // 当前体重(kg)
  final double height;            // 身高(cm)
  final String? note;

  DailyRecord({
    this.id,
    required this.date,
    this.caloriesConsumed = 0,
    this.caloriesGoal = 2000,
    this.waterIntake = 0,
    this.waterGoal = 2000,
    this.exerciseMinutes = 0,
    this.exerciseGoal = 60,
    this.weight = 0,
    this.height = 0,
    this.note,
  });

  double get bmi => weight > 0 && height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

  String get bmiLevel {
    if (bmi <= 0) return '未设置';
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏胖';
    return '肥胖';
  }

  double get caloriesPercent => caloriesGoal > 0 ? (caloriesConsumed / caloriesGoal * 100).clamp(0, 200) : 0;
  double get waterPercent    => waterGoal    > 0 ? (waterIntake    / waterGoal    * 100).clamp(0, 200) : 0;
  double get exercisePercent => exerciseGoal > 0 ? (exerciseMinutes / exerciseGoal * 100).clamp(0, 200) : 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'caloriesConsumed': caloriesConsumed,
    'caloriesGoal': caloriesGoal,
    'waterIntake': waterIntake,
    'waterGoal': waterGoal,
    'exerciseMinutes': exerciseMinutes,
    'exerciseGoal': exerciseGoal,
    'weight': weight,
    'height': height,
    'note': note,
  };

  factory DailyRecord.fromMap(Map<String, dynamic> map) => DailyRecord(
    id: map['id'],
    date: DateTime.parse(map['date']),
    caloriesConsumed: (map['caloriesConsumed'] as num?)?.toDouble() ?? 0,
    caloriesGoal:     (map['caloriesGoal']     as num?)?.toDouble() ?? 2000,
    waterIntake:      (map['waterIntake']       as num?)?.toDouble() ?? 0,
    waterGoal:        (map['waterGoal']         as num?)?.toDouble() ?? 2000,
    exerciseMinutes:  (map['exerciseMinutes']  as int?)   ?? 0,
    exerciseGoal:      (map['exerciseGoal']     as int?)   ?? 60,
    weight:           (map['weight']            as num?)?.toDouble() ?? 0,
    height:           (map['height']            as num?)?.toDouble() ?? 0,
    note:             map['note'],
  );

  DailyRecord copyWith({
    int? id, DateTime? date,
    double? caloriesConsumed, double? caloriesGoal,
    double? waterIntake, double? waterGoal,
    int? exerciseMinutes, int? exerciseGoal,
    double? weight, double? height, String? note,
  }) => DailyRecord(
    id: id ?? this.id,
    date: date ?? this.date,
    caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
    caloriesGoal: caloriesGoal ?? this.caloriesGoal,
    waterIntake: waterIntake ?? this.waterIntake,
    waterGoal: waterGoal ?? this.waterGoal,
    exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
    exerciseGoal: exerciseGoal ?? this.exerciseGoal,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    note: note ?? this.note,
  );
}

/// 饮食条目模型
class FoodEntry {
  final int? id;
  final int recordId;
  final String name;
  final double calories; // 千卡
  final DateTime createdAt;

  FoodEntry({
    this.id,
    required this.recordId,
    required this.name,
    required this.calories,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'recordId': recordId, 'name': name,
    'calories': calories, 'createdAt': createdAt.toIso8601String(),
  };

  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry(
    id: map['id'],
    recordId: map['recordId'],
    name: map['name'],
    calories: (map['calories'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt']),
  );
}