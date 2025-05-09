// lib/data/local/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart'
    hide Table; // !! 需要引入 Material 用于 Icons !!
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart'; // 引入表定义
import 'package:plant_pet_log/models/enum.dart'; // 引入枚举

// 需要生成的文件部分 (运行 build_runner 后会生成)
part 'app_database.g.dart';

// 定义数据库类，使用 @DriftDatabase 注解
// !! 更新注解，包含 CustomEventTypes 表 !!
@DriftDatabase(tables: [Plants, Pets, LogEntries, Reminders, CustomEventTypes])
class AppDatabase extends _$AppDatabase {
  // _$AppDatabase 是 build_runner 生成的类
  AppDatabase() : super(_openConnection());

  // !! schemaVersion 递增为 2 !!
  @override
  int get schemaVersion => 2;

  // 定义数据库升级迁移逻辑 (如果未来版本变化)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      print("Database onCreate: Creating all tables..."); // 添加日志
      await m.createAll(); // 创建所有表 (包括新的 CustomEventTypes)
      print("Database onCreate: All tables created."); // 添加日志
      // 在 onCreate 中插入预设事件类型
      print("Database onCreate: Inserting preset event types..."); // 添加日志
      await _insertPresetEventTypes(this); // 传入 this (AppDatabase 实例)
      print("Database onCreate: Preset event types inserted."); // 添加日志
      // 不再需要插入测试数据
      // await _insertTestData(this);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      print(
        "Database onUpgrade: Running migration from $from to $to",
      ); // Log migration
      if (from < 2) {
        // 如果是从版本 1 升级到 2 或更高
        print("Database onUpgrade: Adding CustomEventTypes table..."); // 添加日志
        await m.createTable(customEventTypes); // 创建新表
        print("Database onUpgrade: CustomEventTypes table added."); // 添加日志
        // 在 onUpgrade 中也插入预设类型 (以防旧用户升级)
        print(
          "Database onUpgrade: Inserting preset event types for upgraded user...",
        ); // 添加日志
        await _insertPresetEventTypes(this); // 传入 this
        print(
          "Database onUpgrade: Preset event types inserted for upgraded user.",
        ); // 添加日志
      }
      // Add other migration steps here if needed for future versions
    },
  );

  /// Helper method to insert preset event types.
  /// Must be static or accept the database instance if called from migration.
  static Future<void> _insertPresetEventTypes(AppDatabase db) async {
    print("Executing _insertPresetEventTypes..."); // 添加日志
    // 使用 batch 提高效率
    await db.batch((batch) {
      // Define preset types for plants
      final List<CustomEventTypesCompanion> plantPresets = [
        // 使用 Value() 包裹非空值，使用 const Value(null) 或省略表示空值 (如果列允许)
        CustomEventTypesCompanion.insert(
          name: '浇水',
          iconCodepoint: Value(Icons.water_drop_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '施肥',
          iconCodepoint: Value(Icons.eco_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '换盆',
          iconCodepoint: Value(Icons.yard_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '修剪',
          iconCodepoint: Value(Icons.cut_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '光照变化',
          iconCodepoint: Value(Icons.lightbulb_outline.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '病虫害',
          iconCodepoint: Value(Icons.bug_report_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
      ];
      // Define preset types for pets
      final List<CustomEventTypesCompanion> petPresets = [
        CustomEventTypesCompanion.insert(
          name: '喂食',
          iconCodepoint: Value(Icons.restaurant_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '用药',
          iconCodepoint: Value(Icons.medical_services_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '疫苗',
          iconCodepoint: Value(Icons.vaccines_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '体内驱虫',
          iconCodepoint: Value(Icons.medication_liquid_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '体外驱虫',
          iconCodepoint: Value(
            Icons.bug_report_outlined.codePoint,
          ), // Re-use bug icon or find another
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '洗澡/美容',
          iconCodepoint: Value(Icons.bathtub_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '体重记录',
          iconCodepoint: Value(Icons.scale_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '行为观察',
          iconCodepoint: Value(Icons.visibility_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
        CustomEventTypesCompanion.insert(
          name: '就诊',
          iconCodepoint: Value(Icons.local_hospital_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
      ];
      // Define a generic "Other" type
      final List<CustomEventTypesCompanion> genericPreset = [
        CustomEventTypesCompanion.insert(
          name: '其他',
          iconCodepoint: Value(Icons.notes_outlined.codePoint),
          iconFontFamily: Value('MaterialIcons'),
          isPreset: const Value(true),
        ),
      ];

      // Use insertAll with mode InsertMode.insertOrIgnore to avoid errors if already inserted
      batch.insertAll(
        db.customEventTypes,
        plantPresets,
        mode: InsertMode.insertOrIgnore,
      );
      batch.insertAll(
        db.customEventTypes,
        petPresets,
        mode: InsertMode.insertOrIgnore,
      );
      batch.insertAll(
        db.customEventTypes,
        genericPreset,
        mode: InsertMode.insertOrIgnore,
      );
      print("Batch insert for presets prepared."); // 添加日志
    });
    print("_insertPresetEventTypes execution finished."); // 添加日志
  }

  // --- Plant 相关操作 (保持不变) ---
  Future<List<Plant>> getAllPlants() => select(plants).get();
  Stream<List<Plant>> watchAllPlants() => select(plants).watch();
  Future<int> insertPlant(PlantsCompanion plant) => into(plants).insert(plant);
  Future<bool> updatePlant(PlantsCompanion plant) =>
      update(plants).replace(plant);
  Future<int> deletePlant(int id) =>
      (delete(plants)..where((tbl) => tbl.id.equals(id))).go();

  // --- Pet 相关操作 (保持不变) ---
  Future<List<Pet>> getAllPets() => select(pets).get();
  Stream<List<Pet>> watchAllPets() => select(pets).watch();
  Future<int> insertPet(PetsCompanion pet) => into(pets).insert(pet);
  Future<bool> updatePet(PetsCompanion pet) => update(pets).replace(pet);
  Future<int> deletePet(int id) =>
      (delete(pets)..where((tbl) => tbl.id.equals(id))).go();

  // --- LogEntry 相关操作 (保持不变) ---
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

  // --- Reminder 相关操作 (保持不变) ---
  Stream<List<Reminder>> watchActiveReminders() {
    return (select(reminders)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]))
        .watch();
  }

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

  // !! ================================================ !!
  // !! 新增: CustomEventType DAO Methods !!
  // !! ================================================ !!

  /// Watches all custom event types (preset and user-defined), ordered by name.
  Stream<List<CustomEventType>> watchAllEventTypes() {
    print("Watching all event types..."); // 添加日志
    // Optionally order by a displayOrder column if added later
    return (select(customEventTypes)
      ..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  /// Gets all custom event types (preset and user-defined), ordered by name.
  Future<List<CustomEventType>> getAllEventTypes() {
    print("Getting all event types..."); // 添加日志
    return (select(customEventTypes)
      ..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
  }

  /// Inserts a new custom event type. Ensures `isPreset` is false.
  Future<int> insertEventType(CustomEventTypesCompanion eventType) {
    // Ensure name is unique (handled by DB constraint)
    // Force isPreset to false for user-added types
    final companion = eventType.copyWith(isPreset: const Value(false));
    print("Inserting new event type: ${companion.name.value}"); // 添加日志
    return into(customEventTypes).insert(companion);
  }

  /// Updates an existing event type.
  /// Note: Logic to prevent editing preset names should be in the UI or service layer.
  Future<bool> updateEventType(CustomEventTypesCompanion eventType) {
    print("Updating event type ID: ${eventType.id.value}"); // 添加日志
    return update(customEventTypes).replace(eventType);
  }

  /// Deletes a custom event type only if it's not a preset type.
  Future<int> deleteEventType(int id) {
    print("Attempting to delete event type ID: $id"); // 添加日志
    // The WHERE clause prevents deleting preset types at the database level
    return (delete(customEventTypes)..where(
      (tbl) => tbl.id.equals(id) & tbl.isPreset.equals(false),
    )) // Ensures only non-presets are deleted
    .go().then((rowCount) {
      // 添加日志显示结果
      if (rowCount > 0) {
        print("Deleted event type ID: $id successfully.");
      } else {
        print("Event type ID: $id not deleted (either not found or preset).");
      }
      return rowCount;
    });
  }

  /// Helper to get icon data for a specific event type name.
  /// Returns `TypedIconData` or null if not found.
  Future<TypedIconData?> getIconForEventType(String eventTypeName) async {
    // print("Getting icon for event type name: $eventTypeName"); // Log might be too frequent
    final type =
        await (select(customEventTypes)
          ..where((tbl) => tbl.name.equals(eventTypeName))).getSingleOrNull();

    if (type != null &&
        type.iconCodepoint != null &&
        type.iconFontFamily != null) {
      // print("Icon found for $eventTypeName: ${type.iconCodepoint}");
      return TypedIconData(
        IconData(type.iconCodepoint!, fontFamily: type.iconFontFamily!),
        // color: type.colorHex != null ? Color(int.parse(type.colorHex!, radix: 16)) : null,
      );
    }
    // print("Icon not found for $eventTypeName, returning default.");
    // Fallback icon if not found or no icon defined
    return TypedIconData(Icons.label_outline); // Use a consistent default icon
  }
} // End of AppDatabase class

/// Helper class to potentially bundle IconData with other info like color in the future.
class TypedIconData {
  final IconData iconData;
  final Color? color; // Example: Add color property if needed
  TypedIconData(this.iconData, {this.color});
}

// Defines the database connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'plant_pet_log_db.sqlite'));
    print("Opening database at: ${file.path}"); // 添加日志
    return NativeDatabase(file);
  });
}
