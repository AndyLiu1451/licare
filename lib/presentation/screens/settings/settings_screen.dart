import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart'; // For picking backup directory
import 'package:plant_pet_log/config/theme/app_theme.dart'; // 引入 AppTheme 获取颜色
import 'package:plant_pet_log/data/local/database/app_database.dart'; // Import database
import 'package:plant_pet_log/providers/database_provider.dart'; // Import database provider
import 'package:plant_pet_log/services/data_management_service.dart'; // Import the service
import 'package:plant_pet_log/providers/theme_provider.dart'; // 引入 theme providers
import 'package:go_router/go_router.dart'; // 引入 GoRouter
import 'package:plant_pet_log/presentation/screens/knowledge/knowledge_base_screen.dart'; // !! 引入知识库页面 !!

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

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '请选择备份保存位置',
    );

    if (selectedDirectory != null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('正在备份...'),
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      success = await dataService.backupDatabase(selectedDirectory);
      message = success ? '备份成功！已保存到选定目录。' : '备份失败。';
    } else {
      message = '备份已取消。';
    }

    if (context.mounted) {
      scaffoldMessenger.removeCurrentSnackBar();
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

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
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
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('恢复已取消')));
      }
      return;
    }

    if (!context.mounted) return;

    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('请选择备份文件...')));
    await Future.delayed(const Duration(milliseconds: 100));

    bool success = await dataService.restoreDatabase();
    String message;

    if (success) {
      message = '恢复成功！请手动重启应用以加载新数据。';
    } else {
      message = '恢复失败或已取消。当前数据未更改。';
    }

    if (context.mounted) {
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // --- Export Action ---
  Future<void> _performExport(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);
    final db = ref.read(databaseProvider);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('正在导出日志数据...'),
        duration: Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));

    // ContextMenuHelper.setContext(context); // Ensure this helper is defined or remove

    try {
      final filePath = await dataService.exportLogsToCsv(db);

      if (context.mounted) {
        scaffoldMessenger.removeCurrentSnackBar();
        if (filePath != null) {
          await dataService.shareFile(filePath, '植物宠物日志导出');
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('没有日志数据可导出。')),
          );
        }
      }
    } catch (e) {
      print("Export failed: $e");
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
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final currentColorIndex = ref.watch(selectedColorIndexProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      children: [
        // --- 外观设置 ---
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
          /* ... ThemeMode.system ... */
          title: const Text('跟随系统'),
          value: ThemeMode.system,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.brightness_auto_outlined),
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          /* ... ThemeMode.light ... */
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
          /* ... ThemeMode.dark ... */
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
          /* ... 主题颜色 Title ... */
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text('主题颜色', style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          /* ... 颜色选择 Wrap ... */
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.start,
            children: List<Widget>.generate(AppTheme.colorThemes.length, (
              int index,
            ) {
              final color = AppTheme.colorThemes[index];
              final bool isSelected = index == currentColorIndex;
              return GestureDetector(
                /* ... 颜色圆形 ... */
                onTap: () {
                  themeNotifier.changeColorIndex(index);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
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
                            ),
                          )
                          : null,
                ),
              );
            }),
          ),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

        // --- 学习与帮助 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '学习与帮助', // 新增分组标题
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          // !! 新增知识库入口 ListTile !!
          leading: const Icon(Icons.local_library_outlined),
          title: const Text('养护知识库'),
          subtitle: const Text('查看常见植物和宠物知识'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            context.goNamed(KnowledgeBaseScreen.routeName); // 跳转到知识库
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

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
          /* ... 备份数据 ... */
          leading: const Icon(Icons.backup_outlined),
          title: const Text('备份数据'),
          subtitle: const Text('将当前数据备份到选定位置'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performBackup(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        ListTile(
          /* ... 恢复数据 ... */
          leading: Icon(Icons.restore_page_outlined, color: Colors.orange[700]),
          title: Text('恢复数据', style: TextStyle(color: Colors.orange[700])),
          subtitle: const Text('从备份文件恢复（覆盖当前数据！）'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performRestore(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        ListTile(
          /* ... 导出日志 ... */
          leading: const Icon(Icons.ios_share_outlined),
          title: const Text('导出日志为 CSV'),
          subtitle: const Text('将日志记录导出为表格文件'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performExport(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        // const Divider(indent: 16, endIndent: 16), // Divider after export? Optional
        // --- 可选：关于页面/信息 ---
        // ListTile(...)
      ],
    );
  }
}
