// lib/providers/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database/app_database.dart'; // 确保这个路径指向你创建的 AppDatabase 类

// 创建一个全局的 Provider 来提供 AppDatabase 的单例实例
final databaseProvider = Provider<AppDatabase>((ref) {
  // 创建数据库实例
  final db = AppDatabase();

  // 当 Provider 不再被使用时，自动关闭数据库连接，释放资源
  ref.onDispose(() {
    print("Closing database connection..."); // 添加日志方便调试
    db.close();
  });

  print("Database Provider Initialized"); // 添加日志方便调试
  return db;
});

// 注意：这个 Provider 的作用是创建并管理 AppDatabase 的唯一实例。
// 其他需要访问数据库的 Provider (如 object_providers.dart 中的) 将会 "watch" 或 "read" 这个 provider 来获取数据库实例。
