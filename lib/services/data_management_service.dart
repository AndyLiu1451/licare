import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb check
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart'; // 引入数据库
import 'package:plant_pet_log/models/enum.dart'; // For enum conversion
import 'package:share_plus/share_plus.dart'; // Optional for sharing

// Riverpod Provider
final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  // 需要访问数据库路径，但不直接操作数据库内容 (备份/恢复是文件操作)
  // 可以传入数据库实例或只传入获取路径的方法
  return DataManagementService();
});

class DataManagementService {
  // 获取当前数据库文件的路径
  Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'plant_pet_log_db.sqlite');
  }

  // --- Backup ---
  Future<bool> backupDatabase(String? targetDirectory) async {
    if (kIsWeb) {
      throw UnsupportedError('Backup is not supported on web.');
    }
    try {
      final String dbPath = await getDatabasePath();
      final File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        print("Database file not found at $dbPath");
        return false;
      }

      // --- 请求权限 (Android) ---
      // 虽然 file_picker 可能处理部分权限，但直接写入特定目录可能需要
      if (Platform.isAndroid) {
        // 检查权限状态
        var status =
            await Permission.manageExternalStorage.status; // 或者 storage
        if (!status.isGranted) {
          // 请求权限
          status =
              await Permission.manageExternalStorage.request(); // 或者 storage
          if (!status.isGranted) {
            print("Storage permission denied.");
            // 可以提示用户去设置开启权限
            // openAppSettings();
            return false;
          }
        }
      }
      // --- 权限检查结束 ---

      String backupFileName =
          'plant_pet_log_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.sqlite';
      String backupPath;

      if (targetDirectory != null) {
        backupPath = p.join(targetDirectory, backupFileName);
      } else {
        // 默认为 Downloads 目录 (需要适配不同平台)
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          // Android 需要特殊处理获取 Downloads 目录，或者使用更可靠的方法
          downloadsDir = Directory(
            '/storage/emulated/0/Download',
          ); // Common path, might fail
          // 更可靠的方式是用 path_provider 的 getExternalStorageDirectories(type: StorageDirectory.downloads)
          // 但可能返回 null 或需要额外设置
          if (!await downloadsDir.exists()) {
            // 尝试 getExternalStorageDirectory
            downloadsDir = await getExternalStorageDirectory(); // 应用专属外部存储
          }
        } else if (Platform.isIOS || Platform.isMacOS) {
          downloadsDir = await getDownloadsDirectory();
        }
        if (downloadsDir == null) {
          print("Could not determine downloads directory.");
          // 回退到应用文档目录
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        backupPath = p.join(downloadsDir.path, backupFileName);
      }

      print("Backing up database to: $backupPath");
      await dbFile.copy(backupPath);
      print("Backup successful!");
      return true;
    } catch (e) {
      print("Backup failed: $e");
      return false;
    }
  }

  // --- Restore ---
  Future<bool> restoreDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Restore is not supported on web.');
    }
    try {
      // 1. 让用户选择备份文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // 或者限定 .sqlite
        // allowedExtensions: ['sqlite'], // 限定扩展名
      );

      if (result != null && result.files.single.path != null) {
        final String backupFilePath = result.files.single.path!;
        final File backupFile = File(backupFilePath);

        if (!await backupFile.exists()) {
          print("Selected backup file does not exist: $backupFilePath");
          return false;
        }

        // 2. 获取当前数据库路径
        final String currentDbPath = await getDatabasePath();
        final File currentDbFile = File(currentDbPath);

        // 3. **重要: 关闭数据库连接 (如果应用正在使用)**
        //    这通常需要在调用 restore 之前，在应用层面关闭 AppDatabase 实例。
        //    如果无法在 Service 中直接关闭，需要在调用方处理。
        //    例如: ref.read(databaseProvider).close(); (需要确保单例)

        // 4. 替换文件
        try {
          // 可以先备份当前文件以防恢复失败
          // await currentDbFile.rename(...);
          await backupFile.copy(currentDbPath); // 用备份文件覆盖当前文件
          print("Database restored successfully from: $backupFilePath");

          // 5. **重要: 重新打开数据库连接**
          //    应用需要重新初始化数据库连接才能使用新文件。
          //    这可能需要重启应用或重新初始化数据库Provider。

          return true;
        } catch (e) {
          print("Error replacing database file: $e");
          // 如果之前备份了，尝试恢复原始文件
          return false;
        }
      } else {
        // User canceled the picker
        print("Restore cancelled by user.");
        return false;
      }
    } catch (e) {
      print("Restore failed: $e");
      return false;
    }
  }

  // --- Export (Example: Export Logs to CSV) ---
  Future<String?> exportLogsToCsv(AppDatabase db) async {
    if (kIsWeb) {
      throw UnsupportedError('Export is not supported on web.');
    }
    try {
      // 1. 从数据库获取所有日志数据
      final List<LogEntry> logs =
          await (db.select(
            db.logEntries,
          )..orderBy([(t) => OrderingTerm(expression: t.eventDateTime)])).get();
      if (logs.isEmpty) {
        print("No logs to export.");
        return null;
      }

      // 2. 获取对象名称映射 (提高可读性)
      final plants = await db.getAllPlants();
      final pets = await db.getAllPets();
      final objectNames = <(int, ObjectType), String>{};
      for (var p in plants) {
        objectNames[(p.id, ObjectType.plant)] = p.name;
      }
      for (var p in pets) {
        objectNames[(p.id, ObjectType.pet)] = p.name;
      }

      // 3. 准备 CSV 数据
      List<List<dynamic>> csvData = [
        // Header row
        [
          'Log ID',
          'Object ID',
          'Object Type',
          'Object Name',
          'Event Type',
          'Event DateTime',
          'Notes',
          'Photo Paths (JSON)',
          'Creation Date',
        ],
      ];

      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

      for (final log in logs) {
        csvData.add([
          log.id,
          log.objectId,
          log.objectType.name, // Use enum name
          objectNames[(log.objectId, log.objectType)] ??
              'Unknown', // Get object name
          log.eventType,
          formatter.format(log.eventDateTime),
          log.notes ?? '',
          log.photoPaths ?? '',
          formatter.format(log.creationDate),
        ]);
      }

      // 4. 将数据转换为 CSV 字符串
      String csvString = const ListToCsvConverter().convert(csvData);

      // 5. 保存 CSV 文件
      final Directory tempDir = await getTemporaryDirectory(); // 保存到临时目录，然后分享
      final String fileName =
          'plant_pet_log_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final String filePath = p.join(tempDir.path, fileName);
      final File csvFile = File(filePath);
      await csvFile.writeAsString(csvString);

      print("CSV export successful to: $filePath");
      return filePath; // 返回文件路径，以便分享
    } catch (e) {
      print("Export to CSV failed: $e");
      return null;
    }
  }

  // --- Share Exported File --- (Optional)
  Future<void> shareFile(String filePath, String subject) async {
    if (kIsWeb) {
      throw UnsupportedError('Sharing is not supported on web.');
    }
    final box =
        ContextMenuHelper.getWidgetContext()?.findRenderObject()
            as RenderBox?; // Need context for share sheet position on iPad
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }
}

// Helper class to get context for Share.shareXFiles positioning on iPad
// This is a bit of a workaround. Ideally, the sharing action would be triggered
// from a widget that has access to its own BuildContext.
class ContextMenuHelper {
  static BuildContext? _context;
  static void setContext(BuildContext? context) => _context = context;
  static BuildContext? getWidgetContext() => _context;
}
