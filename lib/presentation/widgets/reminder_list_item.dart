import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/local/database/app_database.dart';
import '../../models/enum.dart';
import '../../providers/database_provider.dart';
// Import NotificationService and its provider
import '../../services/notification_service.dart';
import 'package:drift/drift.dart' show Value; // Import Value for Companions
import 'package:go_router/go_router.dart';

class ReminderListItem extends ConsumerWidget {
  final Reminder reminder;
  final bool showObjectName;

  const ReminderListItem({
    super.key,
    required this.reminder,
    this.showObjectName = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isOverdue = reminder.isActive && reminder.nextDueDate.isBefore(now);

    final objectNameFuture =
        showObjectName
            ? ref.watch(
              _objectNameProvider((
                id: reminder.objectId,
                type: reminder.objectType,
              )),
            )
            : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      color:
          !reminder.isActive
              ? Colors.grey[300]
              : (isOverdue ? Colors.red[50] : null),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              reminder.objectType == ObjectType.plant
                  ? Icons.local_florist_outlined
                  : Icons.pets_outlined,
              color:
                  reminder.isActive ? theme.colorScheme.primary : Colors.grey,
            ),
            if (!reminder.isActive)
              Text(
                '暂停',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              )
            else if (isOverdue)
              Text(
                '过期',
                style: TextStyle(fontSize: 10, color: Colors.red[700]),
              ),
          ],
        ),
        title: Text(
          reminder.taskName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: !reminder.isActive ? TextDecoration.lineThrough : null,
            color: reminder.isActive ? null : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showObjectName && objectNameFuture != null)
              objectNameFuture.when(
                data:
                    (name) => Text(
                      name ?? '未知对象',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.disabledColor,
                      ),
                    ),
                loading:
                    () => const SizedBox(
                      height: 14,
                      child: Text('加载中...', style: TextStyle(fontSize: 12)),
                    ),
                error:
                    (_, __) => const Text(
                      '错误',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
              ),
            Row(
              children: [
                Icon(
                  Icons.alarm,
                  size: 14,
                  color:
                      isOverdue && reminder.isActive
                          ? Colors.red[700]
                          : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${dateFormatter.format(reminder.nextDueDate)} ${timeFormatter.format(reminder.nextDueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isOverdue && reminder.isActive
                            ? Colors.red[700]
                            : Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (reminder.frequencyRule != 'ONCE')
              Text(
                _formatFrequencyRule(reminder.frequencyRule),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (reminder.notes != null && reminder.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  reminder.notes!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            // Use the helper methods defined below
            switch (result) {
              case 'toggle_active':
                _toggleReminderActive(context, ref, reminder);
                break;
              case 'edit':
                _navigateToEditReminder(context, reminder.id);
                break;
              case 'delete':
                _confirmDeleteReminder(context, ref, reminder);
                break;
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'toggle_active',
                  child: Text(reminder.isActive ? '暂停提醒' : '激活提醒'),
                ),
                const PopupMenuItem<String>(value: 'edit', child: Text('编辑')),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('删除', style: TextStyle(color: Colors.red)),
                ),
              ],
          icon: const Icon(Icons.more_vert),
        ),
        onTap: () {
          _navigateToEditReminder(context, reminder.id);
        },
      ),
    );
  }

  String _formatFrequencyRule(String rule) {
    // (Keep the existing _formatFrequencyRule implementation)
    if (rule.startsWith('DAILY')) return '每天';
    if (rule.startsWith('WEEKLY')) return '每周 (${rule.split(':')[1]})';
    if (rule.startsWith('MONTHLY')) return '每月 ${rule.split(':')[1]} 号';
    if (rule.startsWith('EVERY')) {
      final parts = rule.split(':');
      if (parts.length == 3) {
        String unit;
        switch (parts[2]) {
          case 'days':
            unit = '天';
            break;
          case 'weeks':
            unit = '周';
            break;
          case 'months':
            unit = '月';
            break;
          default:
            unit = parts[2];
        }
        return '每 ${parts[1]} $unit';
      }
    }
    return rule;
  }

  // Internal provider for object name caching
  static final _objectNameProvider = FutureProvider.autoDispose
      .family<String?, ({int id, ObjectType type})>((ref, params) async {
        final db = ref.read(databaseProvider);
        if (params.type == ObjectType.plant) {
          final plant =
              await (db.select(db.plants)
                ..where((tbl) => tbl.id.equals(params.id))).getSingleOrNull();
          return plant?.name;
        } else {
          final pet =
              await (db.select(db.pets)
                ..where((tbl) => tbl.id.equals(params.id))).getSingleOrNull();
          return pet?.name;
        }
      });

  // --- Action Handlers ---

  // Toggle Reminder Active Status
  // Toggle Reminder Active Status
  Future<void> _toggleReminderActive(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final db = ref.read(databaseProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final bool newActiveState = !reminder.isActive; // Determine the new state

    // --- Corrected Update Logic ---
    // Use update()..where()..write() to update only specific fields
    final updateStatement = db.update(
      db.reminders,
    ) // Target the reminders table
    ..where((tbl) => tbl.id.equals(reminder.id)); // Filter by the reminder's ID

    try {
      // Write only the isActive field with the new value
      final affectedRows = await updateStatement.write(
        RemindersCompanion(isActive: Value(newActiveState)),
      );
      // --- End Corrected Update Logic ---

      if (affectedRows > 0) {
        // Check if any row was actually updated
        // --- Notification Logic (remains the same) ---
        if (newActiveState) {
          // Need the full reminder object to schedule
          // Re-fetch the reminder to ensure we have the latest data (optional but safer)
          final updatedReminder = await db.getReminder(reminder.id);
          if (updatedReminder != null) {
            print(
              "Scheduling notification for re-activated reminder ${reminder.id}",
            );
            await notificationService.scheduleReminderNotification(
              updatedReminder,
            );
          } else {
            print(
              "Could not fetch updated reminder ${reminder.id} after activating.",
            ); // Handle error case
          }
        } else {
          print("Cancelling notification for paused reminder ${reminder.id}");
          await notificationService.cancelNotification(reminder.id);
        }
        // --- End Notification Logic ---

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提醒已${newActiveState ? "激活" : "暂停"}')),
          );
        }
      } else {
        // This case might happen if the reminder was deleted concurrently
        print(
          "Warning: Toggle active state failed, reminder with id ${reminder.id} might not exist.",
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('操作失败: 提醒可能已被删除'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print("Error toggling reminder state: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Navigate to Edit Reminder Screen
  void _navigateToEditReminder(BuildContext context, int reminderId) {
    // Ensure you have the route defined in go_router
    try {
      GoRouter.of(context).pushNamed(
        'editReminder',
        pathParameters: {'id': reminderId.toString()},
      );
    } catch (e) {
      print("Error navigating to editReminder: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法导航到编辑页面: $e')));
    }
  }

  // Confirm and Delete Reminder
  Future<void> _confirmDeleteReminder(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除提醒?'),
            content: Text('确定要删除任务 "${reminder.taskName}" 吗？此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (result == true) {
      final db = ref.read(databaseProvider);
      // Get notification service
      final notificationService = ref.read(notificationServiceProvider);
      final int reminderIdToDelete = reminder.id; // Store ID

      try {
        // 1. Delete from database
        await db.deleteReminder(reminderIdToDelete);

        // --- Notification Logic ---
        // 2. Cancel the corresponding notification
        print(
          "Cancelling notification for deleted reminder $reminderIdToDelete",
        );
        await notificationService.cancelNotification(reminderIdToDelete);
        // --- End Notification Logic ---

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('提醒已删除')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

// Ensure GoRouter is imported if used for navigation
