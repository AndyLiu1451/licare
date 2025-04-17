// lib/providers/object_providers.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database/app_database.dart';
import '../models/enum.dart';
import 'database_provider.dart';
import 'list_filter_providers.dart'; // 引入排序/筛选状态 Provider
import 'package:drift/drift.dart'
    show
        BooleanExpressionOperators,
        ComparableExpr,
        Expression,
        OrderingMode,
        OrderingTerm,
        StringExpressionOperators,
        Value,
        Variable; // 引入 Drift 排序类

// --- Statistics Providers ---

// Provider for Pet Weight History Data (formatted for fl_chart)
// Takes Pet ID as input (using .family)
final petWeightChartDataProvider = FutureProvider.autoDispose.family<
  List<FlSpot>,
  int
>((ref, petId) async {
  final db = ref.read(
    databaseProvider,
  ); // Use read for one-time fetch needed for chart data

  // 1. 查询该宠物所有类型为 '体重记录' 的日志 (假设事件类型存储为此字符串)
  // TODO: 确保 '体重记录' 字符串与你实际存储的一致
  const weightEventType = '体重记录'; // 或者使用枚举值

  // Drift doesn't directly support casting text to double in query easily for ordering/filtering number in notes.
  // Fetch all weight logs and process in Dart.
  final weightLogs =
      await (db.select(db.logEntries)
            ..where(
              (tbl) =>
                  tbl.objectId.equals(petId) &
                  tbl.objectType.equals(ObjectType.pet.index) &
                  tbl.eventType.equals(weightEventType),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.eventDateTime),
            ]) // 按时间排序
            )
          .get();

  // 2. 处理日志数据，转换为 FlSpot 列表
  final List<FlSpot> spots = [];
  for (final log in weightLogs) {
    // 假设体重数据存储在 notes 字段，需要解析
    final double? weight = double.tryParse(log.notes ?? ''); // 尝试将备注解析为 double
    if (weight != null && weight > 0) {
      // 确保体重有效
      // X轴: 使用日期的毫秒时间戳 (或者距离某个基准日期的天数)
      final double timeInMillis =
          log.eventDateTime.millisecondsSinceEpoch.toDouble();
      // Y轴: 体重值
      spots.add(FlSpot(timeInMillis, weight));
    } else {
      print(
        "Warning: Could not parse weight from log note: '${log.notes}' for log id ${log.id}",
      );
    }
  }

  // 如果数据点少于2个，无法形成有效的线图，可以返回空或少量数据
  // if (spots.length < 2) {
  //    return []; // Or handle appropriately in the UI
  // }

  return spots;
});

// TODO: Add providers for other statistics (e.g., event frequency)
// Example: Plant Watering Frequency (last 30 days)
// final plantWateringFrequencyProvider = FutureProvider.autoDispose.family<Map<DateTime, int>, int>((ref, plantId) async {
//    final db = ref.read(databaseProvider);
//    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
//    const wateringEventType = '浇水';
//
//    final logs = await (db.select(db.logEntries)
//                          ..where((tbl) => tbl.objectId.equals(plantId) &
//                                         tbl.objectType.equals(ObjectType.plant.index) &
//                                         tbl.eventType.equals(wateringEventType) &
//                                         tbl.eventDateTime.isBiggerOrEqualValue(thirtyDaysAgo))
//                         ).get();
//
//    final Map<DateTime, int> dailyCounts = {};
//    for (final log in logs) {
//       final dateOnly = DateTime(log.eventDateTime.year, log.eventDateTime.month, log.eventDateTime.day);
//       dailyCounts[dateOnly] = (dailyCounts[dateOnly] ?? 0) + 1;
//    }
//    return dailyCounts; // UI can use this Map to build a BarChart
// });

// --- Plant Providers ---
// 修改 plantListStreamProvider 以支持排序
final plantListStreamProvider = StreamProvider.autoDispose<List<Plant>>((ref) {
  final db = ref.watch(databaseProvider);
  final sortOption = ref.watch(plantSortOptionProvider);
  final searchQuery = ref.watch(searchQueryProvider); // !! 监听搜索词

  final query = db.select(db.plants);

  // !! 应用搜索过滤 (如果搜索词不为空)
  if (searchQuery.trim().isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    // 搜索 名称(name) 或 昵称(nickname) 或 品种(species)
    query.where(
      (tbl) =>
          tbl.name.lower().like('%$lowerCaseQuery%') | // 使用 | 代表 OR
          tbl.nickname.lower().like('%$lowerCaseQuery%') |
          tbl.species.lower().like('%$lowerCaseQuery%'),
    );
    // .lower() 转换为小写进行不区分大小写搜索
    // .like('%...%') 进行模糊匹配
  }

  // 应用排序
  switch (sortOption) {
    case PlantSortOption.nameAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.name)]);
      break;
    case PlantSortOption.nameDesc:
      query.orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.desc),
      ]);
      break;
    case PlantSortOption.dateAddedAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.creationDate)]);
      break;
    case PlantSortOption.dateAddedDesc:
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.creationDate, mode: OrderingMode.desc),
      ]);
      break;
  }

  return query.watch(); // 返回带排序的查询流
});

// !! 新增: 提供单个植物详情的 Provider (按需加载, 返回可空类型)
final plantDetailsProvider = StreamProvider.autoDispose.family<Plant?, int>((
  ref,
  plantId,
) {
  final db = ref.watch(databaseProvider);
  // 使用 watchSingleOrNull 监听单个对象的变化
  return (db.select(db.plants)
    ..where((tbl) => tbl.id.equals(plantId))).watchSingleOrNull();
});

// !! 新增: 提供特定植物日志条目流的 Provider
final plantLogStreamProvider = StreamProvider.autoDispose
    .family<List<LogEntry>, int>((ref, plantId) {
      final db = ref.watch(databaseProvider);
      return db.watchLogsForObject(
        plantId,
        ObjectType.plant,
      ); // 使用之前在 AppDatabase 中定义的方法
    });

// --- Pet Providers ---
// 修改 petListStreamProvider 以支持排序
final petListStreamProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final db = ref.watch(databaseProvider);
  final sortOption = ref.watch(petSortOptionProvider);
  final searchQuery = ref.watch(searchQueryProvider); // !! 监听搜索词

  final query = db.select(db.pets);

  // !! 应用搜索过滤
  if (searchQuery.trim().isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    // 搜索 名称(name) 或 昵称(nickname) 或 品种(species) 或 具体品种(breed)
    query.where(
      (tbl) =>
          tbl.name.lower().like('%$lowerCaseQuery%') |
          tbl.nickname.lower().like('%$lowerCaseQuery%') |
          tbl.species.lower().like('%$lowerCaseQuery%') |
          tbl.breed.lower().like('%$lowerCaseQuery%'),
    );
  }

  switch (sortOption) {
    case PetSortOption.nameAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.name)]);
      break;
    case PetSortOption.nameDesc:
      query.orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.desc),
      ]);
      break;
    case PetSortOption.dateAddedAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.creationDate)]);
      break;
    case PetSortOption.dateAddedDesc:
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.creationDate, mode: OrderingMode.desc),
      ]);
      break;
    case PetSortOption.birthDateAsc:
      // 注意: 生日可能为 null，排序时需要处理
      // Drift 默认 nulls first，可以接受
      query.orderBy([
        (t) => OrderingTerm(expression: t.birthDate),
      ]); // nulls first
      // 如果想 nulls last: query.orderBy([(t) => OrderingTerm(expression: t.birthDate.isNull(), mode: OrderingMode.desc), (t) => OrderingTerm(expression: t.birthDate)]);
      break;
    case PetSortOption.birthDateDesc:
      query.orderBy([
        (t) => OrderingTerm(expression: t.birthDate, mode: OrderingMode.desc),
      ]); // nulls last (desc)
      break;
  }

  return query.watch();
});

// !! 新增: 提供单个宠物详情的 Provider
final petDetailsProvider = StreamProvider.autoDispose.family<Pet?, int>((
  ref,
  petId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.pets)
    ..where((tbl) => tbl.id.equals(petId))).watchSingleOrNull();
});

// !! 新增: 提供特定宠物日志条目流的 Provider
final petLogStreamProvider = StreamProvider.autoDispose
    .family<List<LogEntry>, int>((ref, petId) {
      final db = ref.watch(databaseProvider);
      return db.watchLogsForObject(petId, ObjectType.pet);
    });

// --- Reminder Providers (如果还没加) ---

// 重构提醒 Provider 以同时处理排序和筛选
final filteredSortedRemindersStreamProvider = StreamProvider.autoDispose<
  List<Reminder>
>((ref) {
  final db = ref.watch(databaseProvider);
  final sortOption = ref.watch(reminderSortOptionProvider);
  final filterOption = ref.watch(reminderFilterOptionProvider);
  final searchQuery = ref.watch(searchQueryProvider); // !! 监听搜索词

  final query = db.select(db.reminders);

  // 应用筛选条件
  final now = DateTime.now();
  switch (filterOption) {
    case ReminderFilterOption.activeOnly:
      query.where((tbl) => tbl.isActive.equals(true));
      break;
    case ReminderFilterOption.inactiveOnly:
      query.where((tbl) => tbl.isActive.equals(false));
      break;
    case ReminderFilterOption.overdueOnly:
      // 只筛选激活且过期的
      query.where(
        (tbl) =>
            tbl.isActive.equals(true) & tbl.nextDueDate.isSmallerThanValue(now),
      );
      break;
    case ReminderFilterOption.all:
      // No filter applied
      break;
  }
  // !! 应用搜索过滤 (搜索任务名称 taskName 或 备注 notes)
  if (searchQuery.trim().isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    query.where(
      (tbl) =>
          tbl.taskName.lower().like('%$lowerCaseQuery%') |
          tbl.notes.lower().like('%$lowerCaseQuery%'),
    );
  }

  // 应用排序条件
  switch (sortOption) {
    case ReminderSortOption.dueDateAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]);
      break;
    case ReminderSortOption.dueDateDesc:
      query.orderBy([
        (t) => OrderingTerm(expression: t.nextDueDate, mode: OrderingMode.desc),
      ]);
      break;
    case ReminderSortOption.nameAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.taskName)]);
      break;
    case ReminderSortOption.nameDesc:
      query.orderBy([
        (t) => OrderingTerm(expression: t.taskName, mode: OrderingMode.desc),
      ]);
      break;
    case ReminderSortOption.dateAddedAsc:
      query.orderBy([(t) => OrderingTerm(expression: t.creationDate)]);
      break;
    case ReminderSortOption.dateAddedDesc:
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.creationDate, mode: OrderingMode.desc),
      ]);
      break;
  }

  return query.watch();
});

// 1. 提供所有提醒的流 Provider (用于管理视图或筛选)
final allRemindersStreamProvider = StreamProvider.autoDispose<List<Reminder>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db.watchAllReminders(); // 获取所有提醒，包括非激活的
});

// 2. 提供按截止日期排序的激活提醒的流 Provider (用于主提醒列表)
final activeRemindersStreamProvider =
    StreamProvider.autoDispose<List<Reminder>>((ref) {
      final db = ref.watch(databaseProvider);
      return db.watchActiveReminders(); // 只获取激活的，按日期排序
    });

// 3. 提供特定对象提醒列表流的 Provider (之前已添加，用于详情页等)
final objectRemindersStreamProvider = StreamProvider.autoDispose
    .family<List<Reminder>, ({int objectId, ObjectType objectType})>((
      ref,
      params,
    ) {
      final db = ref.watch(databaseProvider);
      return db.watchRemindersForObject(params.objectId, params.objectType);
    });

// 4. (可选) 提供单个提醒详情的 Provider
final reminderDetailsProvider = StreamProvider.autoDispose
    .family<Reminder?, int>((ref, reminderId) {
      final db = ref.watch(databaseProvider);
      return (db.select(db.reminders)
        ..where((tbl) => tbl.id.equals(reminderId))).watchSingleOrNull();
    });

// 5. (用于添加/编辑提醒) 提供关联对象列表的 Provider
// 这个 Provider 用于在添加/编辑提醒时，让用户选择关联哪个植物或宠物
// 它需要合并植物和宠物列表，并提供一个统一的表示
final selectableObjectsProvider =
    FutureProvider.autoDispose<List<SelectableObject>>((ref) async {
      final db = ref.read(databaseProvider); // 用 read，因为只需要获取一次列表
      final plants = await db.getAllPlants();
      final pets = await db.getAllPets();

      final List<SelectableObject> selectableList = [];
      for (var plant in plants) {
        selectableList.add(
          SelectableObject(
            id: plant.id,
            name: plant.name,
            type: ObjectType.plant,
          ),
        );
      }
      for (var pet in pets) {
        selectableList.add(
          SelectableObject(id: pet.id, name: pet.name, type: ObjectType.pet),
        );
      }
      // 可以按名称排序
      selectableList.sort((a, b) => a.name.compareTo(b.name));
      return selectableList;
    });

// 定义一个简单的类来表示可选择的对象
class SelectableObject {
  final int id;
  final String name;
  final ObjectType type;

  SelectableObject({required this.id, required this.name, required this.type});

  // 用于 DropdownMenuItem 的显示
  String get displayName => '${type == ObjectType.plant ? "[植]" : "[宠]"} $name';
}
