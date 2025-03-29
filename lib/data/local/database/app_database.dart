import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart'; // 引入表定义
import 'package:plant_pet_log/models/enum.dart'; // 引入枚举

// 需要生成的文件部分 (运行 build_runner 后会生成)
part 'app_database.g.dart';

// 定义数据库类，使用 @DriftDatabase 注解
@DriftDatabase(tables: [Plants, Pets, LogEntries, Reminders])
class AppDatabase extends _$AppDatabase {
  // _$AppDatabase 是 build_runner 生成的类
  AppDatabase() : super(_openConnection());

  // schemaVersion 用于数据库迁移
  @override
  int get schemaVersion => 1;

  // 定义数据库升级迁移逻辑 (如果未来版本变化)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // --- 临时添加测试数据 ---
      // 注意： Drift 生成的 Companion 类用于插入和更新
      await batch((batch) {
        batch.insertAll(plants, [
          PlantsCompanion.insert(
            name: '绿萝',
            nickname: const Value('小绿'),
            creationDate: DateTime.now(),
            species: const Value('Epipremnum aureum'),
            room: const Value('客厅'),
          ),
          PlantsCompanion.insert(
            name: '多肉拼盘',
            creationDate: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ]);
        batch.insertAll(pets, [
          PetsCompanion.insert(
            name: '旺财',
            nickname: const Value('狗子'),
            creationDate: DateTime.now(),
            species: const Value('犬'),
            breed: const Value('中华田园犬'),
            birthDate: Value(DateTime(2022, 5, 1)),
            gender: Value(Gender.male), // 使用 Value 包裹可空枚举
          ),
          PetsCompanion.insert(
            name: '咪咪',
            creationDate: DateTime.now().subtract(const Duration(days: 100)),
            species: const Value('猫'),
            breed: const Value('英短蓝猫'),
            gender: Value(Gender.female),
          ),
        ]);
      });
      // --- 测试数据结束 ---
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 例如，如果从版本1升级到版本2
      // if (from == 1) {
      //   await m.addColumn(logs, logs.someNewColumn);
      // }
    },
  );

  // --- Plant 相关操作 ---
  Future<List<Plant>> getAllPlants() => select(plants).get();
  Stream<List<Plant>> watchAllPlants() => select(plants).watch();
  Future<int> insertPlant(PlantsCompanion plant) => into(plants).insert(plant);
  Future<bool> updatePlant(PlantsCompanion plant) =>
      update(plants).replace(plant);
  Future<int> deletePlant(int id) =>
      (delete(plants)..where((tbl) => tbl.id.equals(id))).go();

  // --- Pet 相关操作 ---
  Future<List<Pet>> getAllPets() => select(pets).get();
  Stream<List<Pet>> watchAllPets() => select(pets).watch();
  Future<int> insertPet(PetsCompanion pet) => into(pets).insert(pet);
  Future<bool> updatePet(PetsCompanion pet) => update(pets).replace(pet);
  Future<int> deletePet(int id) =>
      (delete(pets)..where((tbl) => tbl.id.equals(id))).go();

  // --- LogEntry 相关操作 ---
  Stream<List<LogEntry>> watchLogsForObject(int objectId, ObjectType type) {
    return (select(logEntries)
          ..where(
            (tbl) =>
                tbl.objectId.equals(objectId) &
                tbl.objectType.equals(type.index),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.eventDateTime,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<int> insertLogEntry(LogEntriesCompanion entry) =>
      into(logEntries).insert(entry);
  Future<bool> updateLogEntry(LogEntriesCompanion entry) =>
      update(logEntries).replace(entry);
  Future<int> deleteLogEntry(int id) =>
      (delete(logEntries)..where((tbl) => tbl.id.equals(id))).go();

  // --- Reminder 相关操作 ---
  Stream<List<Reminder>> watchActiveReminders() {
    return (select(reminders)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]))
        .watch();
  }

  // 获取所有提醒，包括非激活的，用于管理
  Stream<List<Reminder>> watchAllReminders() {
    return (select(reminders)
      ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)])).watch();
  }

  Future<Reminder?> getReminder(int id) =>
      (select(reminders)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);
  Future<bool> updateReminder(RemindersCompanion reminder) =>
      update(reminders).replace(reminder);
  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((tbl) => tbl.id.equals(id))).go();
  // 可能还需要一个方法来获取特定对象的所有提醒
  Stream<List<Reminder>> watchRemindersForObject(
    int objectId,
    ObjectType type,
  ) {
    return (select(reminders)
          ..where(
            (tbl) =>
                tbl.objectId.equals(objectId) &
                tbl.objectType.equals(type.index),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]))
        .watch();
  }
}

// 定义数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    final file = File(
      p.join(dbFolder.path, 'plant_pet_log_db.sqlite'),
    ); // 数据库文件名
    return NativeDatabase(file); // 创建数据库连接
  });
}
