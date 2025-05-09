import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/list_filter_providers.dart'; // 引入搜索和过滤/排序 Provider

// MainScreen 需要是 ConsumerStatefulWidget 来管理搜索 UI 状态
class MainScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  // Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Optional: Listen for external search query changes
  }

  @override
  void dispose() {
    _searchController.dispose();
    // _debounce?.cancel();
    super.dispose();
  }

  // 构建 AppBar
  AppBar _buildAppBar(AppLocalizations l10n) {
    // !! 传入 l10n !!
    final currentTabIndex = widget.navigationShell.currentIndex;
    String titleText = '';
    switch (currentTabIndex) {
      case 0:
        titleText = l10n.myPlants;
        break; // !! 使用 l10n !!
      case 1:
        titleText = l10n.myPets;
        break; // !! 使用 l10n !!
      case 2:
        titleText = l10n.upcomingReminders;
        break; // !! 使用 l10n !!
      case 3:
        titleText = l10n.settings;
        break; // !! 使用 l10n !!
      default:
        titleText = l10n.appTitle; // !! 使用 l10n !!
    }

    if (_isSearching) {
      // --- 搜索状态 AppBar ---
      return AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          tooltip:
              MaterialLocalizations.of(
                context,
              ).backButtonTooltip, // Use standard tooltip
          onPressed: () {
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = '';
            }
            if (mounted) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            }
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '${l10n.search}...', // !! 使用 l10n !!
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          cursorColor: Theme.of(context).appBarTheme.foregroundColor,
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              tooltip:
                  l10n.cancelSelection, // Re-use a suitable term? Or add 'clearSearch'
              onPressed: () {
                ref.read(searchQueryProvider.notifier).state = '';
                if (mounted) {
                  _searchController.clear();
                }
              },
            ),
        ],
      );
    } else {
      // --- 正常状态 AppBar ---
      return AppBar(
        title: Text(titleText),
        actions: [
          if (currentTabIndex < 3)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search, // !! 使用 l10n !!
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isSearching = true;
                  });
                }
              },
            ),

          // --- 排序/筛选按钮 ---
          if (currentTabIndex == 0) // 植物
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(plantSortOptionProvider);
                return PopupMenuButton<PlantSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.sort, // !! 使用 l10n !!
                  onSelected:
                      (PlantSortOption result) =>
                          ref.read(plantSortOptionProvider.notifier).state =
                              result,
                  itemBuilder:
                      (BuildContext context) => _buildPlantSortMenuItems(
                        l10n,
                        currentSortOption,
                      ), // !! 传入 l10n !!
                );
              },
            ),
          if (currentTabIndex == 1) // 宠物
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(petSortOptionProvider);
                return PopupMenuButton<PetSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.sort, // !! 使用 l10n !!
                  onSelected:
                      (PetSortOption result) =>
                          ref.read(petSortOptionProvider.notifier).state =
                              result,
                  itemBuilder:
                      (BuildContext context) => _buildPetSortMenuItems(
                        l10n,
                        currentSortOption,
                      ), // !! 传入 l10n !!
                );
              },
            ),
          if (currentTabIndex == 2) ...[
            // 提醒
            Consumer(
              builder: (context, ref, _) {
                final currentFilterOption = ref.watch(
                  reminderFilterOptionProvider,
                );
                return PopupMenuButton<ReminderFilterOption>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: l10n.filter, // !! 使用 l10n !!
                  onSelected:
                      (ReminderFilterOption result) =>
                          ref
                              .read(reminderFilterOptionProvider.notifier)
                              .state = result,
                  itemBuilder:
                      (BuildContext context) => _buildReminderFilterMenuItems(
                        l10n,
                        currentFilterOption,
                      ), // !! 传入 l10n !!
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(reminderSortOptionProvider);
                return PopupMenuButton<ReminderSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.sort, // !! 使用 l10n !!
                  onSelected:
                      (ReminderSortOption result) =>
                          ref.read(reminderSortOptionProvider.notifier).state =
                              result,
                  itemBuilder:
                      (BuildContext context) => _buildReminderSortMenuItems(
                        l10n,
                        currentSortOption,
                      ), // !! 传入 l10n !!
                );
              },
            ),
          ],
        ],
      );
    }
  }

  // --- Helper methods to build menu items ---

  // !! 修改辅助方法以接收 AppLocalizations l10n !!
  List<PopupMenuEntry<PlantSortOption>> _buildPlantSortMenuItems(
    AppLocalizations l10n,
    PlantSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: PlantSortOption.nameAsc,
        checked: current == PlantSortOption.nameAsc,
        child: Text(l10n.sortNameAsc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: PlantSortOption.nameDesc,
        checked: current == PlantSortOption.nameDesc,
        child: Text(l10n.sortNameDesc),
      ), // !! 使用 l10n !!
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PlantSortOption.dateAddedDesc,
        checked: current == PlantSortOption.dateAddedDesc,
        child: Text(l10n.sortDateAddedDesc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: PlantSortOption.dateAddedAsc,
        checked: current == PlantSortOption.dateAddedAsc,
        child: Text(l10n.sortDateAddedAsc),
      ), // !! 使用 l10n !!
    ];
  }

  List<PopupMenuEntry<PetSortOption>> _buildPetSortMenuItems(
    AppLocalizations l10n,
    PetSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: PetSortOption.nameAsc,
        checked: current == PetSortOption.nameAsc,
        child: Text(l10n.sortNameAsc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: PetSortOption.nameDesc,
        checked: current == PetSortOption.nameDesc,
        child: Text(l10n.sortNameDesc),
      ), // !! 使用 l10n !!
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PetSortOption.birthDateAsc,
        checked: current == PetSortOption.birthDateAsc,
        child: Text(l10n.sortBirthDateAsc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: PetSortOption.birthDateDesc,
        checked: current == PetSortOption.birthDateDesc,
        child: Text(l10n.sortBirthDateDesc),
      ), // !! 使用 l10n !!
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PetSortOption.dateAddedDesc,
        checked: current == PetSortOption.dateAddedDesc,
        child: Text(l10n.sortDateAddedDesc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: PetSortOption.dateAddedAsc,
        checked: current == PetSortOption.dateAddedAsc,
        child: Text(l10n.sortDateAddedAsc),
      ), // !! 使用 l10n !!
    ];
  }

  List<PopupMenuEntry<ReminderFilterOption>> _buildReminderFilterMenuItems(
    AppLocalizations l10n,
    ReminderFilterOption current,
  ) {
    // Use a Map for cleaner text lookup
    final Map<ReminderFilterOption, String> filterLabels = {
      ReminderFilterOption.activeOnly: l10n.filterActiveOnly,
      ReminderFilterOption.overdueOnly: l10n.filterOverdueOnly,
      ReminderFilterOption.inactiveOnly: l10n.filterInactiveOnly,
      ReminderFilterOption.all: l10n.filterAll,
    };
    // Define the order
    final List<ReminderFilterOption> orderedOptions = [
      ReminderFilterOption.activeOnly,
      ReminderFilterOption.overdueOnly,
      ReminderFilterOption.inactiveOnly,
      ReminderFilterOption.all,
    ];

    List<PopupMenuEntry<ReminderFilterOption>> items =
        orderedOptions.map((option) {
          return CheckedPopupMenuItem<ReminderFilterOption>(
            value: option,
            checked: current == option,
            child: Text(filterLabels[option] ?? '?'), // Use map for label
          );
        }).toList();

    // Insert divider before 'All' (which is now the last item in orderedOptions)
    items.insert(items.length - 1, const PopupMenuDivider());
    return items;
  }

  List<PopupMenuEntry<ReminderSortOption>> _buildReminderSortMenuItems(
    AppLocalizations l10n,
    ReminderSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateAsc,
        checked: current == ReminderSortOption.dueDateAsc,
        child: Text(l10n.sortDueDateAsc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateDesc,
        checked: current == ReminderSortOption.dueDateDesc,
        child: Text(l10n.sortDueDateDesc),
      ), // !! 使用 l10n !!
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameAsc,
        checked: current == ReminderSortOption.nameAsc,
        child: Text(l10n.sortNameAsc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameDesc,
        checked: current == ReminderSortOption.nameDesc,
        child: Text(l10n.sortNameDesc),
      ), // !! 使用 l10n !!
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedDesc,
        checked: current == ReminderSortOption.dateAddedDesc,
        child: Text(l10n.sortDateAddedDesc),
      ), // !! 使用 l10n !!
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedAsc,
        checked: current == ReminderSortOption.dateAddedAsc,
        child: Text(l10n.sortDateAddedAsc),
      ), // !! 使用 l10n !!
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!

    return Scaffold(
      appBar: _buildAppBar(l10n), // !! 传递 l10n 给 AppBar 构建方法 !!
      body: PopScope(
        // Use PopScope for back button handling during search
        canPop: !_isSearching,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (_isSearching) {
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = '';
            }
            if (mounted) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            }
          }
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // Use const if possible
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_florist_outlined),
            activeIcon: const Icon(Icons.local_florist),
            label: l10n.plants, // !! 使用 l10n !!
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pets_outlined),
            activeIcon: const Icon(Icons.pets),
            label: l10n.pets, // !! 使用 l10n !!
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: l10n.reminders, // !! 使用 l10n !!
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settings, // !! 使用 l10n !!
          ),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          if (_isSearching) {
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = '';
            }
            if (mounted) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            }
          }
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
