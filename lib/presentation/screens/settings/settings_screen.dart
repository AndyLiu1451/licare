import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart'; // For picking backup directory
import 'package:plant_pet_log/config/theme/app_theme.dart'; // 引入 AppTheme 获取颜色
import 'package:plant_pet_log/data/local/database/app_database.dart'; // Import database
import 'package:plant_pet_log/providers/database_provider.dart'; // Import database provider
import 'package:plant_pet_log/services/data_management_service.dart'; // Import the service
import 'package:plant_pet_log/providers/theme_provider.dart'; // 引入 theme providers

// Helper to pass context to service if needed for sharing
// Ensure this helper class exists or remove its usage if not strictly needed for share sheet positioning
// import 'package:plant_pet_log/services/data_management_service.dart' show ContextMenuHelper;

class SettingsScreen extends ConsumerWidget {
  static const routeName = 'settings'; // Add route name if not present
  const SettingsScreen({super.key});

  // --- Backup Action ---
  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);
    bool success = false;
    String? message;

    // Ask user where to save (optional, but recommended for non-sandboxed access)
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '请选择备份保存位置',
    );

    if (selectedDirectory != null) {
      // Show progress indicator briefly
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('正在备份...'),
          duration: Duration(seconds: 1),
        ),
      );
      // Wait a bit for the snackbar to show before potentially blocking operation
      await Future.delayed(const Duration(milliseconds: 300));

      success = await dataService.backupDatabase(selectedDirectory);
      message = success ? '备份成功！已保存到选定目录。' : '备份失败。';
    } else {
      // User canceled directory selection
      message = '备份已取消。';
    }

    // Ensure the widget is still mounted before showing the final snackbar
    if (context.mounted) {
      scaffoldMessenger.removeCurrentSnackBar(); // Remove "正在备份..." snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              success
                  ? Colors.green
                  : (message == '备份已取消。' ? null : Colors.red),
        ),
      );
    }
  }

  // --- Restore Action ---
  Future<void> _performRestore(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);

    // Show confirmation dialog - VERY IMPORTANT
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose
      builder:
          (dialogContext) => AlertDialog(
            // Use dialogContext
            title: const Text('确认恢复数据?'),
            content: const Text(
              '将使用选定的备份文件覆盖当前所有数据！\n\n'
              '**强烈建议您先执行一次备份。**\n\n'
              '恢复成功后，应用将需要重启才能加载新数据。\n\n'
              '确定要继续吗？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('继续恢复'),
              ),
            ],
          ),
    );

    if (confirm != true) {
      if (context.mounted) {
        // Check if context is still valid
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('恢复已取消')));
      }
      return;
    }

    // --- Close DB Connection (Instruct user to restart) ---
    // No code here to close DB, rely on user restarting

    if (!context.mounted) return; // Check context before showing next snackbar

    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('请选择备份文件...')));
    // Delay slightly to allow snackbar to show before file picker potentially blocks UI
    await Future.delayed(const Duration(milliseconds: 100));

    bool success = await dataService.restoreDatabase();
    String message;

    if (success) {
      message = '恢复成功！请手动重启应用以加载新数据。';
    } else {
      message = '恢复失败或已取消。当前数据未更改。';
    }

    if (context.mounted) {
      // Check context again before showing final result
      scaffoldMessenger.removeCurrentSnackBar(); // Remove "请选择..." snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(
            seconds: 6,
          ), // Longer duration for restart message
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // --- Export Action ---
  Future<void> _performExport(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);
    final db = ref.read(databaseProvider); // Need db instance for export

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('正在导出日志数据...'),
        duration: Duration(seconds: 1),
      ),
    );
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Allow snackbar to show

    // Set context for potential iPad share UI positioning
    // ContextMenuHelper.setContext(context); // Ensure this helper is defined or remove if not needed

    try {
      final filePath = await dataService.exportLogsToCsv(db);

      if (context.mounted) {
        // Check context before interacting with UI
        scaffoldMessenger.removeCurrentSnackBar(); // Remove "正在导出..." snackbar
        if (filePath != null) {
          // Ask user to share/save the file
          await dataService.shareFile(filePath, '植物宠物日志导出');
          // Note: No success snackbar needed here as share sheet handles completion.
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('没有日志数据可导出。')),
          );
        }
      }
    } catch (e) {
      print("Export failed: $e"); // Log the error for debugging
      if (context.mounted) {
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // ContextMenuHelper.setContext(null); // Clear context if used
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取当前主题状态
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final currentColorIndex = ref.watch(selectedColorIndexProvider);
    // 获取 ThemeNotifier 用于调用方法
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    // !! 移除 Scaffold 和 AppBar !!
    // 直接返回 ListView
    return ListView(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 16.0,
      ), // Add some padding
      children: [
        // --- 主题设置 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '外观',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('跟随系统'),
          value: ThemeMode.system,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.brightness_auto_outlined),
          dense: true, // Make it a bit more compact
        ),
        RadioListTile<ThemeMode>(
          title: const Text('浅色模式'),
          value: ThemeMode.light,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.wb_sunny_outlined),
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          title: const Text('深色模式'),
          value: ThemeMode.dark,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.nightlight_round),
          dense: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            8.0,
          ), // Adjust padding
          child: Text(
            '主题颜色',
            style: Theme.of(context).textTheme.titleMedium,
          ), // Use titleMedium
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Wrap(
            // 使用 Wrap 显示颜色选项
            spacing: 12.0, // Increase spacing slightly
            runSpacing: 12.0,
            alignment: WrapAlignment.start, // Align items to the start
            children: List<Widget>.generate(AppTheme.colorThemes.length, (
              int index,
            ) {
              final color = AppTheme.colorThemes[index];
              final bool isSelected = index == currentColorIndex;
              return GestureDetector(
                onTap: () {
                  themeNotifier.changeColorIndex(index); // 直接调用 Notifier 的方法
                },
                child: Container(
                  width: 44, // Slightly larger tap target
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      // Add a subtle border always
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                  // Use a nested container for the selection indicator for better alignment
                  child:
                      isSelected
                          ? Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                                color,
                                              ) ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.black.withOpacity(0.8),
                                  width: 3.0,
                                ),
                              ),
                              // Optional: Add check mark inside the inner circle
                              // child: Icon(Icons.check, size: 20, color: Colors.white),
                            ),
                          )
                          : null,
                ),
              );
            }),
          ),
        ),
        const Divider(
          height: 32,
          indent: 16,
          endIndent: 16,
        ), // Add indent to divider
        // --- 数据管理 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '数据管理',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('备份数据'),
          subtitle: const Text('将当前数据备份到选定位置'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
          ), // Smaller trailing icon
          onTap: () => _performBackup(context, ref),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Standard padding
        ),
        ListTile(
          leading: Icon(Icons.restore_page_outlined, color: Colors.orange[700]),
          title: Text('恢复数据', style: TextStyle(color: Colors.orange[700])),
          subtitle: const Text('从备份文件恢复（覆盖当前数据！）'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performRestore(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        ListTile(
          leading: const Icon(
            Icons.ios_share_outlined,
          ), // Or Icons.table_chart_outlined
          title: const Text('导出日志为 CSV'),
          subtitle: const Text('将日志记录导出为表格文件'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performExport(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        const Divider(indent: 16, endIndent: 16), // Add indent to divider
        // --- 可选：关于页面/信息 ---
        // ListTile(
        //   leading: const Icon(Icons.info_outline),
        //   title: const Text('关于'),
        //   trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        //   onTap: () { /* Navigate to About Screen */},
        //   contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        // )
      ],
    );
  }
}
