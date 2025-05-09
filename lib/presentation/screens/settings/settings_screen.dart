// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
// !! 引入生成的本地化类 !!
import '../../../l10n/app_localizations.dart';

import 'package:plant_pet_log/config/theme/app_theme.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/providers/database_provider.dart';
import 'package:plant_pet_log/services/data_management_service.dart';
import 'package:plant_pet_log/providers/theme_provider.dart';
import 'package:plant_pet_log/presentation/screens/knowledge/knowledge_base_screen.dart';
import 'manage_event_types_screen.dart';

// Ensure this helper class exists or remove its usage if not strictly needed
// import 'package:plant_pet_log/services/data_management_service.dart' show ContextMenuHelper;

class SettingsScreen extends ConsumerWidget {
  static const routeName = 'settings';
  const SettingsScreen({super.key});

  // --- Backup Action ---
  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);
    bool success = false;
    String? message;

    // 使用 l10n 获取本地化字符串
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.selectBackupFile, // !! 使用 l10n !!
    );

    if (selectedDirectory != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.backupInProgress), // !! 使用 l10n !!
          duration: const Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      success = await dataService.backupDatabase(selectedDirectory);
      message =
          success
              ? l10n.backupSuccess
              : l10n.errorBackupFailed; // !! 使用 l10n !!
    } else {
      message = l10n.backupCancelled; // !! 使用 l10n !!
    }

    if (context.mounted) {
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              success
                  ? Colors.green
                  : (message == l10n.backupCancelled
                      ? null
                      : Colors.red), // !! 比较 l10n 字符串 !!
        ),
      );
    }
  }

  // --- Restore Action ---
  Future<void> _performRestore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.restoreConfirmTitle), // !! 使用 l10n !!
            content: Text(l10n.restoreConfirmDesc), // !! 使用 l10n !!
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel), // !! 使用 l10n !!
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.restoreContinue), // !! 使用 l10n !!
              ),
            ],
          ),
    );

    if (confirm != true) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.restoreCancelled)),
        ); // !! 使用 l10n !!
      }
      return;
    }

    if (!context.mounted) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(l10n.selectBackupFile)),
    ); // !! 使用 l10n !!
    await Future.delayed(const Duration(milliseconds: 100));

    bool success = await dataService.restoreDatabase();
    String message;

    if (success) {
      message = l10n.restoreSuccess; // !! 使用 l10n !!
    } else {
      message = l10n.errorRestoreFailed; // !! 使用 l10n !!
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
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dataService = ref.read(dataManagementServiceProvider);
    final db = ref.read(databaseProvider);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(l10n.exportingLogs), // !! 使用 l10n !!
        duration: const Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));

    // ContextMenuHelper.setContext(context);

    try {
      final filePath = await dataService.exportLogsToCsv(db);

      if (context.mounted) {
        scaffoldMessenger.removeCurrentSnackBar();
        if (filePath != null) {
          // !! 考虑将 subject 本地化 !!
          await dataService.shareFile(
            filePath,
            l10n.exportLogs,
          ); // Example: Use exportLogs key
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.noLogsToExport)), // !! 使用 l10n !!
          );
        }
      }
    } catch (e) {
      print("Export failed: $e");
      if (context.mounted) {
        scaffoldMessenger.removeCurrentSnackBar();
        // !! 使用带占位符的 l10n !!
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorExportFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // ContextMenuHelper.setContext(null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final currentColorIndex = ref.watch(selectedColorIndexProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    // !! 如果需要，获取当前语言环境用于显示 !!
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    return ListView(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      children: [
        // --- 外观设置 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.appearance, // !! 使用 l10n !!
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: Text(l10n.systemTheme), // !! 使用 l10n !!
          value: ThemeMode.system,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.brightness_auto_outlined),
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          title: Text(l10n.lightTheme), // !! 使用 l10n !!
          value: ThemeMode.light,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.wb_sunny_outlined),
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          title: Text(l10n.darkTheme), // !! 使用 l10n !!
          value: ThemeMode.dark,
          groupValue: currentThemeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeNotifier.changeThemeMode(value);
          },
          secondary: const Icon(Icons.nightlight_round),
          dense: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            l10n.themeColor,
            style: Theme.of(context).textTheme.titleMedium,
          ), // !! 使用 l10n !!
        ),
        Padding(
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
                onTap: () {
                  themeNotifier.changeColorIndex(index);
                },
                child: Container(/* ... 颜色圆形 ... */),
              );
            }),
          ),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

        // --- 语言设置 (如果实现了切换功能) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.language, // <--- 需要在 arb 文件中添加 "language": "语言 (Language)"
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        RadioListTile<Locale?>(
          title: Text(l10n.systemTheme), // Reuse system theme string
          value: null,
          groupValue: currentLocale,
          onChanged: (Locale? value) => localeNotifier.changeLocale(value),
          secondary: const Icon(Icons.language),
          dense: true,
        ),
        RadioListTile<Locale?>(
          title: const Text('简体中文'), // Or use a localized string
          value: const Locale('zh'),
          groupValue: currentLocale,
          onChanged: (Locale? value) => localeNotifier.changeLocale(value),
          dense: true,
        ),
        RadioListTile<Locale?>(
          title: const Text('English'), // Or use a localized string
          value: const Locale('en'),
          groupValue: currentLocale,
          onChanged: (Locale? value) => localeNotifier.changeLocale(value),
          dense: true,
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

        // --- 学习与帮助 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.learningHelp, // !! 使用 l10n !!
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.local_library_outlined),
          title: Text(l10n.knowledgeBase), // !! 使用 l10n !!
          subtitle: Text(
            l10n.knowledgeBaseDesc,
          ), // !! 需要在 arb 添加 "knowledgeBaseDesc": "查看常见植物和宠物知识" !!
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            context.goNamed(KnowledgeBaseScreen.routeName);
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

        // --- 自定义 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '自定义', // !! 需要添加到 arb: "customization": "自定义" !!
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: Text(l10n.manageEventTypes), // !! 使用 l10n !!
          subtitle: Text(l10n.manageEventTypesDesc), // !! 使用 l10n !!
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            context.goNamed(ManageEventTypesScreen.routeName);
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),

        // --- 数据管理 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.dataManagement, // !! 使用 l10n !!
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(l10n.backupData), // !! 使用 l10n !!
          subtitle: Text(l10n.backupDataDesc), // !! 使用 l10n !!
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performBackup(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        ListTile(
          leading: Icon(Icons.restore_page_outlined, color: Colors.orange[700]),
          title: Text(
            l10n.restoreData,
            style: TextStyle(color: Colors.orange[700]),
          ), // !! 使用 l10n !!
          subtitle: Text(l10n.restoreDataDesc), // !! 使用 l10n !!
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performRestore(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        ListTile(
          leading: const Icon(Icons.ios_share_outlined),
          title: Text(l10n.exportLogs), // !! 使用 l10n !!
          subtitle: Text(l10n.exportLogsDesc), // !! 使用 l10n !!
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _performExport(context, ref),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ],
    );
  }
}
