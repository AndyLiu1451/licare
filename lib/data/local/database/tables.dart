import 'package:drift/drift.dart';
import 'package:plant_pet_log/models/enum.dart'; // 引入枚举

// 使用 Table mixin 定义表结构

// 植物表
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get nickname => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get creationDate => dateTime()();
  TextColumn get species => text().nullable()();
  DateTimeColumn get acquisitionDate => dateTime().nullable()();
  TextColumn get room => text().nullable()();
  // 类型列，虽然是植物表，但为了与宠物表结构部分对应，保留概念 (也可以不加)
  // IntColumn get type => intEnum<ObjectType>()(); // 如果统一放一张表则需要
}

// 宠物表
class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get nickname => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get creationDate => dateTime()();
  TextColumn get species => text().nullable()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  IntColumn get gender => intEnum<Gender>().nullable()();
}

// 日志条目表 (统一存储植物和宠物的日志)
class LogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get objectId => integer()(); // 关联 Plants.id 或 Pets.id
  IntColumn get objectType => intEnum<ObjectType>()(); // 区分是植物还是宠物
  TextColumn get eventType => text().withLength(min: 1, max: 50)();
  DateTimeColumn get eventDateTime => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPaths => text().nullable()(); // 存储JSON List<String>
  DateTimeColumn get creationDate => dateTime()();

  // 可以考虑添加索引提高查询效率
  // @override
  // List<Set<Column>> get uniqueKeys => []; // 如果需要唯一约束
  // @override
  // List<String> get customConstraints => ['FOREIGN KEY(objectId)...']; // 暂不加外键约束以简化，依赖应用逻辑保证
}

// 提醒表 (统一存储植物和宠物的提醒)
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get objectId => integer()(); // 关联 Plants.id 或 Pets.id
  IntColumn get objectType => intEnum<ObjectType>()(); // 区分是植物还是宠物
  TextColumn get taskName => text().withLength(min: 1, max: 150)();
  TextColumn get frequencyRule =>
      text()(); // e.g., 'ONCE', 'DAILY', 'WEEKLY:MON,FRI'
  DateTimeColumn get nextDueDate => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get creationDate => dateTime()();
}
