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

  // Helper methods to build menu items using l10n
  List<PopupMenuEntry<ReminderFilterOption>> _buildReminderFilterMenuItems(
    BuildContext context,
    ReminderFilterOption current,
  ) {
    final l10n = AppLocalizations.of(context)!; // Get l10n instance
    return ReminderFilterOption.values.map((option) {
        String text;
        switch (option) {
          case ReminderFilterOption.activeOnly:
            text = l10n.filterActiveOnly; // Use l10n
            break;
          case ReminderFilterOption.overdueOnly:
            text = l10n.filterOverdueOnly; // Use l10n
            break;
          case ReminderFilterOption.inactiveOnly:
            text = l10n.filterInactiveOnly; // Use l10n
            break;
          case ReminderFilterOption.all:
            text = l10n.filterAll; // Use l10n
            break;
        }
        return CheckedPopupMenuItem<ReminderFilterOption>(
          value: option,
          checked: current == option,
          child: Text(text),
        );
      }).toList()
      ..insert(
        3,
        const PopupMenuDivider() as CheckedPopupMenuItem<ReminderFilterOption>,
      ); // Divider position might need adjustment based on enum order
  }

  List<PopupMenuEntry<ReminderSortOption>> _buildReminderSortMenuItems(
    BuildContext context,
    ReminderSortOption current,
  ) {
    final l10n = AppLocalizations.of(context)!; // Get l10n instance
    return [
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateAsc,
        checked: current == ReminderSortOption.dueDateAsc,
        child: Text(l10n.sortDueDateAsc),
      ), // Use l10n
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateDesc,
        checked: current == ReminderSortOption.dueDateDesc,
        child: Text(l10n.sortDueDateDesc),
      ), // Use l10n
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameAsc,
        checked: current == ReminderSortOption.nameAsc,
        child: Text(l10n.sortNameAsc),
      ), // Use l10n
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameDesc,
        checked: current == ReminderSortOption.nameDesc,
        child: Text(l10n.sortNameDesc),
      ), // Use l10n
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedDesc,
        checked: current == ReminderSortOption.dateAddedDesc,
        child: Text(l10n.sortDateAddedDesc),
      ), // Use l10n
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedAsc,
        checked: current == ReminderSortOption.dateAddedAsc,
        child: Text(l10n.sortDateAddedAsc),
      ), // Use l10n
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final remindersAsyncValue = ref.watch(
      filteredSortedRemindersStreamProvider,
    );
    final currentFilterOption = ref.watch(reminderFilterOptionProvider);
    final currentSortOption = ref.watch(
      reminderSortOptionProvider,
    ); // Watch sort option

    return Scaffold(
      // Wrap content in Scaffold for AppBar
      appBar: AppBar(
        title: Text(l10n.upcomingReminders), // !! 使用 l10n !!
        // Add actions back to the AppBar
        actions: [
          // Filter Button
          PopupMenuButton<ReminderFilterOption>(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filter, // !! 使用 l10n !!
            onSelected: (ReminderFilterOption result) {
              ref.read(reminderFilterOptionProvider.notifier).state = result;
            },
            // Call helper method to build items
            itemBuilder:
                (BuildContext context) =>
                    _buildReminderFilterMenuItems(context, currentFilterOption),
          ),
          // Sort Button
          PopupMenuButton<ReminderSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sort, // !! 使用 l10n !!
            onSelected: (ReminderSortOption result) {
              ref.read(reminderSortOptionProvider.notifier).state = result;
            },
            // Call helper method to build items
            itemBuilder:
                (BuildContext context) =>
                    _buildReminderSortMenuItems(context, currentSortOption),
          ),
        ],
      ),
      // Body uses Stack for FAB positioning
      body: Stack(
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
                        '\n' +
                        l10n.addReminder; // Combine messages
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
      ),
    );
  }
}
