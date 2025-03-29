// lib/providers/object_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database/app_database.dart';
import '../models/enum.dart';
import 'database_provider.dart';

// --- Plant Providers ---
final plantListStreamProvider = StreamProvider.autoDispose<List<Plant>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllPlants();
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
final petListStreamProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllPets();
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
// (稍后实现提醒列表页时再详细添加，这里先放一个基础的)
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
