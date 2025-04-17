import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 全局搜索状态 ---
// 使用 .autoDispose，当没有页面监听时自动重置搜索词
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// --- 植物列表状态 ---

// 排序选项枚举
enum PlantSortOption { nameAsc, nameDesc, dateAddedAsc, dateAddedDesc }

// 筛选选项 (可以扩展，例如按房间) - 暂不实现筛选

// Provider for current sort option
final plantSortOptionProvider = StateProvider<PlantSortOption>(
  (ref) => PlantSortOption.nameAsc,
); // 默认按名称升序

// --- 宠物列表状态 ---

enum PetSortOption {
  nameAsc,
  nameDesc,
  dateAddedAsc,
  dateAddedDesc,
  birthDateAsc,
  birthDateDesc,
}

final petSortOptionProvider = StateProvider<PetSortOption>(
  (ref) => PetSortOption.nameAsc,
);

// --- 提醒列表状态 ---

enum ReminderSortOption {
  dueDateAsc,
  dueDateDesc,
  nameAsc,
  nameDesc,
  dateAddedAsc,
  dateAddedDesc,
}

enum ReminderFilterOption { all, activeOnly, inactiveOnly, overdueOnly } // 筛选

final reminderSortOptionProvider = StateProvider<ReminderSortOption>(
  (ref) => ReminderSortOption.dueDateAsc,
); // 默认按截止日期升序
final reminderFilterOptionProvider = StateProvider<ReminderFilterOption>(
  (ref) => ReminderFilterOption.activeOnly,
); // 默认只显示激活
