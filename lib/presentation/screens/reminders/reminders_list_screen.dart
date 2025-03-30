// lib/presentation/screens/reminders/reminders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation
// Removed unused imports: drift, app_database, enum, database_provider, notification_service

import '../../../providers/object_providers.dart'; // Import Provider
import '../../widgets/reminder_list_item.dart'; // Import list item Widget

class RemindersListScreen extends ConsumerWidget {
  static const routeName = 'remindersList';
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the active reminders stream (more common for a "To-Do" view)
    final remindersAsyncValue = ref.watch(activeRemindersStreamProvider);
    // If you want to keep showing ALL reminders by default, uncomment the line below
    // and comment out the line above. Adjust AppBar title accordingly.
    // final remindersAsyncValue = ref.watch(allRemindersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        // Updated title to reflect showing active reminders
        title: const Text('待办提醒'),
        // TODO: Add filter/sort options here later if needed
        // actions: [
        //    IconButton(icon: Icon(Icons.filter_list), onPressed: () { /* Show filter options */ })
        // ],
      ),
      body: remindersAsyncValue.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            // Updated empty state message slightly for clarity
            return const Center(
              child: Text(
                '没有待办提醒。\n点击右下角按钮添加一个吧！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            // Using ListView.separated for better visual spacing
            return ListView.separated(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ReminderListItem(
                  reminder: reminder,
                  showObjectName:
                      true, // Show associated object name in the list
                );
              },
              separatorBuilder:
                  (context, index) => const SizedBox(
                    height: 0,
                  ), // No visible separator needed with Cards
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          print('Error loading active reminders: $error');
          return Center(child: Text('加载提醒失败: $error'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        // --- Updated onPressed Logic ---
        onPressed: () {
          print('Add Reminder FAB tapped!'); // <-- 添加这行
          // 确保使用了正确的命名路由跳转
          context.goNamed('addReminder');
        },
        // --- End of Updated onPressed Logic ---
        tooltip: '添加提醒',
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
