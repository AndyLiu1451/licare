// lib/presentation/screens/reminders/reminders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation
import '../../../providers/list_filter_providers.dart'; // 引入状态 Provider
// Removed unused imports: drift, app_database, enum, database_provider, notification_service

import '../../../providers/object_providers.dart'; // Import Provider
import '../../widgets/reminder_list_item.dart'; // Import list item Widget

class RemindersListScreen extends ConsumerWidget {
  static const routeName = 'remindersList';
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the active reminders stream (more common for a "To-Do" view)
    // 使用新的组合 Provider
    final remindersAsyncValue = ref.watch(
      filteredSortedRemindersStreamProvider,
    );

    final currentFilterOption = ref.watch(reminderFilterOptionProvider);

    return Stack(
      children: [
        remindersAsyncValue.when(
          data: (reminders) {
            if (reminders.isEmpty) {
              String emptyMessage = '没有符合条件的提醒。';
              switch (currentFilterOption) {
                case ReminderFilterOption.activeOnly:
                  emptyMessage = '没有待办提醒。';
                  break;
                case ReminderFilterOption.overdueOnly:
                  emptyMessage = '没有已过期的提醒。';
                  break;
                case ReminderFilterOption.inactiveOnly:
                  emptyMessage = '没有已暂停的提醒。';
                  break;
                case ReminderFilterOption.all:
                  emptyMessage = '还没有添加任何提醒。\n可以点击右下角按钮添加。';
                  break;
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ReminderListItem(
                    reminder: reminder,
                    showObjectName: true,
                  );
                },
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('加载提醒失败: $error', textAlign: TextAlign.center),
                ),
              ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'fab_reminder_list',
            onPressed: () {
              context.goNamed('addReminder');
            },
            tooltip: '添加提醒',
            child: const Icon(Icons.add_alert),
          ),
        ),
      ],
    );
  }
}
