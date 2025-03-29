// lib/presentation/screens/reminders/reminders_list_screen.dart
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/models/enum.dart';
import 'package:plant_pet_log/providers/database_provider.dart';
import 'package:plant_pet_log/services/notification_service.dart';
import '../../../providers/object_providers.dart'; // 引入 Provider
import '../../widgets/reminder_list_item.dart'; // 引入列表项 Widget

class RemindersListScreen extends ConsumerWidget {
  // 改为 ConsumerWidget
  static const routeName = 'remindersList';
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 添加 WidgetRef
    // 监听激活的提醒列表流
    //final remindersAsyncValue = ref.watch(activeRemindersStreamProvider);
    // 或者监听所有提醒:
    final remindersAsyncValue = ref.watch(allRemindersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('所有提醒'),
        // 可以添加筛选或排序按钮
        // actions: [
        //    IconButton(icon: Icon(Icons.filter_list), onPressed: () { /* TODO */ })
        // ],
      ),
      body: remindersAsyncValue.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return const Center(
              child: Text(
                '还没有添加任何提醒。\n可以在植物或宠物详情页添加提醒，\n或点击右下角按钮添加。', // 调整提示
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ReminderListItem(
                  reminder: reminder,
                  showObjectName: true,
                ); // 在列表页显示对象名称
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          print('Error loading reminders: $error');
          return Center(child: Text('加载提醒失败: $error'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final db = ref.read(databaseProvider);
          final now = DateTime.now();
          final reminderCompanion = RemindersCompanion.insert(
            objectId: 1, // 假设关联ID为1的对象存在
            objectType: ObjectType.plant,
            taskName: '测试通知 ${now.second}',
            frequencyRule: 'ONCE',
            nextDueDate: now.add(const Duration(minutes: 1)), // 1分钟后触发
            isActive: const Value(true),
            creationDate: now,
          );
          final newId = await db.insertReminder(reminderCompanion);
          final newReminder = await db.getReminder(newId);
          if (newReminder != null) {
            await ref
                .read(notificationServiceProvider)
                .scheduleReminderNotification(newReminder);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('测试提醒 (ID: $newId) 已安排在1分钟后')),
            );
          }
        },
        tooltip: '添加提醒',
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
