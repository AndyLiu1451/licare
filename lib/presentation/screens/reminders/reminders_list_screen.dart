// lib/presentation/screens/reminders/reminders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// !! 引入生成的本地化类 !!
import '../../../l10n/app_localizations.dart';
// 引入状态 Provider
import '../../../providers/list_filter_providers.dart';
// Import Provider
import '../../../providers/object_providers.dart';
// Import list item Widget
import '../../widgets/reminder_list_item.dart';

class RemindersListScreen extends ConsumerWidget {
  static const routeName = 'remindersList';
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final remindersAsyncValue = ref.watch(
      filteredSortedRemindersStreamProvider,
    );
    final currentFilterOption = ref.watch(reminderFilterOptionProvider);
    // final currentSortOption = ref.watch(reminderSortOptionProvider); // This is not used in the body anymore

    // Body uses Stack for FAB positioning
    return Stack(
      children: [
        remindersAsyncValue.when(
          data: (reminders) {
            if (reminders.isEmpty) {
              String emptyMessage;
              // !! 使用 l10n !!
              switch (currentFilterOption) {
                case ReminderFilterOption.activeOnly:
                  emptyMessage = l10n.noActiveReminders;
                  break;
                case ReminderFilterOption.overdueOnly:
                  emptyMessage = l10n.noOverdueReminders;
                  break;
                case ReminderFilterOption.inactiveOnly:
                  emptyMessage = l10n.noInactiveReminders;
                  break;
                case ReminderFilterOption.all:
                  emptyMessage =
                      l10n.noRemindersFound +
                      '\n' + // Ensure newline character is correctly escaped for Dart string
                      l10n.addReminder; 
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
                padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ReminderListItem(
                    reminder: reminder,
                    showObjectName: true, // Keep showing object name in list
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
                  // !! 使用 l10n 并传入参数 !!
                  child: Text(
                    l10n.loadingFailed(error.toString()),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
        // FAB remains positioned at the bottom right
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag:
                'fab_reminder_list', // Ensure unique heroTag if multiple FABs exist
            onPressed: () {
              context.goNamed('addReminder'); // Use GoRouter navigation
            },
            tooltip: l10n.addReminder, // !! 使用 l10n !!
            child: const Icon(Icons.add_alert),
          ),
        ),
      ],
    );
  }
}
