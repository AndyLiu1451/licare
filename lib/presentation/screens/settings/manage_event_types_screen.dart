// lib/presentation/screens/settings/manage_event_types_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/providers/database_provider.dart';
import 'package:plant_pet_log/providers/knowledge_provider.dart'; // Or event_type_providers.dart
import 'package:plant_pet_log/presentation/widgets/add_edit_event_type_dialog.dart';
import '../../../l10n/app_localizations.dart';

class ManageEventTypesScreen extends ConsumerWidget {
  static const routeName = 'manageEventTypes';

  const ManageEventTypesScreen({super.key});

  // --- Helper Methods ---

  Future<void> _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    CustomEventType? eventType,
  }) async {
    // !! 2. 获取 l10n 实例 (如果需要在方法内部使用) !!
    // final l10n = AppLocalizations.of(context)!; // 如果下面的 SnackBar 需要本地化

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => AddEditEventTypeDialog(existingType: eventType),
    );

    if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // !! 3. 使用 l10n !! (假设你已在 .arb 文件中添加了相应的 key)
          // content: Text(l10n.errorSavingEventTypeFailed), // 示例 Key
          content: const Text("保存事件类型失败（可能名称已存在）"), // 保持现有，或添加 Key
          backgroundColor: Colors.red,
        ),
      );
    } else if (result == true) {
      print("Add/Edit Event Type Dialog returned success.");
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomEventType eventType,
  ) async {
    // !! 2. 获取 l10n 实例 !!
    final l10n = AppLocalizations.of(context)!;

    if (eventType.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeletePreset)), // !! 3. 使用 l10n !!
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            // Use dialogContext
            title: Text(l10n.confirmDeleteTitle), // !! 3. 使用 l10n !!
            // !! 3. 使用带占位符的 l10n !!
            content: Text(l10n.deleteEventTypeConfirmation(eventType.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel), // !! 3. 使用 l10n !!
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.delete), // !! 3. 使用 l10n !!
              ),
            ],
          ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      try {
        await db.deleteEventType(eventType.id);
        ScaffoldMessenger.of(context).showSnackBar(
          // !! 3. 使用 l10n !! (假设 key 为 eventTypeDeleted)
          // const SnackBar(content: Text(l10n.eventTypeDeleted)),
          const SnackBar(content: Text('事件类型已删除')), // 保持现有，或添加 Key
        );
      } catch (e) {
        print("Error deleting event type: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // !! 3. 使用带占位符的 l10n !!
            content: Text(l10n.errorDeletingFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // !! 2. 获取 l10n 实例 !!
    final l10n = AppLocalizations.of(context)!;
    final eventTypesAsync = ref.watch(allEventTypesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        // !! 3. 使用 l10n !!
        title: Text(l10n.manageEventTypes),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            // !! 3. 使用 l10n !! (假设 key 为 addNewTypeTooltip)
            // tooltip: l10n.addNewTypeTooltip,
            tooltip: '添加新类型', // 保持现有，或添加 Key
            onPressed: () => _showAddEditDialog(context, ref),
          ),
        ],
      ),
      body: eventTypesAsync.when(
        data: (eventTypes) {
          if (eventTypes.isEmpty) {
            // !! 3. 使用 l10n !! (假设 key 为 noEventTypes)
            // return Center(child: Text(l10n.noEventTypes));
            return const Center(child: Text('没有事件类型，请添加。')); // 保持现有，或添加 Key
          }
          return ListView.builder(
            itemCount: eventTypes.length,
            itemBuilder: (context, index) {
              final type = eventTypes[index];
              final iconData =
                  type.iconCodepoint != null && type.iconFontFamily != null
                      ? IconData(
                        type.iconCodepoint!,
                        fontFamily: type.iconFontFamily!,
                      )
                      : Icons.label_outline; // Default icon

              return ListTile(
                leading: Icon(iconData),
                title: Text(type.name), // 类型名称本身可能不需要翻译，因为是用户输入的
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: l10n.edit, // !! 3. 使用 l10n !!
                      onPressed:
                          () =>
                              _showAddEditDialog(context, ref, eventType: type),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: type.isPreset ? Colors.grey : Colors.red,
                      ),
                      // !! 3. 使用 l10n !!
                      tooltip:
                          type.isPreset ? l10n.cannotDeletePreset : l10n.delete,
                      onPressed:
                          type.isPreset
                              ? null
                              : () => _confirmDelete(context, ref, type),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              // !! 3. 使用带占位符的 l10n !!
              child: Text(l10n.loadingFailed(err.toString())),
            ),
      ),
    );
  }
}
