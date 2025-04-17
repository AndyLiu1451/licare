import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/list_filter_providers.dart'; // 引入搜索和过滤/排序 Provider

// MainScreen 需要是 ConsumerStatefulWidget 来管理搜索 UI 状态
class MainScreen extends ConsumerStatefulWidget {
  // !! 改为 ConsumerStatefulWidget
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // !! 创建 State
  bool _isSearching = false; // 状态：是否处于搜索模式
  final TextEditingController _searchController =
      TextEditingController(); // 搜索框控制器
  // Timer? _debounce; // Optional: for debouncing search input

  @override
  void initState() {
    super.initState();
    // 可选: 监听搜索 Provider 的外部变化 (例如代码清除)
    // 使用 listenManual 可能更好，因为它不会在每次 build 时都重新订阅
    // ref.listenManual(searchQueryProvider, (prev, next) {
    //   if (next.isEmpty && _searchController.text.isNotEmpty && mounted) {
    //     _searchController.clear();
    //     if (_isSearching) {
    //       setState(() { _isSearching = false; });
    //     }
    //   }
    // });

    // 添加 listener 以便在需要时更新 provider (或使用 onChanged)
    // _searchController.addListener(_updateSearchQuery);
  }

  // 可选: 更新搜索 Provider 的函数 (配合 addListener 和 debounce)
  // void _updateSearchQuery() {
  //    _debounce?.cancel();
  //    _debounce = Timer(const Duration(milliseconds: 300), () {
  //        if (mounted) { // Check if mounted before accessing ref
  //           ref.read(searchQueryProvider.notifier).state = _searchController.text;
  //        }
  //    });
  // }

  @override
  void dispose() {
    _searchController.dispose();
    // _debounce?.cancel(); // Dispose timer if using debounce
    super.dispose();
  }

  // 构建 AppBar (根据是否搜索切换)
  AppBar _buildAppBar() {
    final currentTabIndex = widget.navigationShell.currentIndex;
    String titleText = ''; // 根据当前 Tab 设置标题
    switch (currentTabIndex) {
      case 0:
        titleText = '我的植物';
        break;
      case 1:
        titleText = '我的宠物';
        break;
      case 2:
        titleText = '待办提醒';
        break;
      case 3:
        titleText = '设置';
        break;
      default:
        titleText = '植宠日志';
    }

    // 获取当前主题的亮度，用于适配 AppBar 图标颜色
    final Brightness brightness = Theme.of(context).brightness;
    final Color iconColor =
        brightness == Brightness.dark ? Colors.white : Colors.black; // 简单判断图标颜色
    // 或者使用 Theme.of(context).appBarTheme.foregroundColor

    if (_isSearching) {
      // --- 搜索状态下的 AppBar ---
      return AppBar(
        leading: IconButton(
          // 返回按钮 (退出搜索)
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          tooltip: '退出搜索',
          onPressed: () {
            // 确保在 setState 前后访问 ref
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = ''; // 清空搜索状态
            }
            // 确保在 mounted 状态下调用 setState
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
          autofocus: true, // 自动获取焦点
          decoration: InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none, // 无边框
            hintStyle: TextStyle(color: Theme.of(context).hintColor), // 使用主题提示色
          ),
          // 使用主题的文本样式
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          cursorColor: Theme.of(context).appBarTheme.foregroundColor,
          // 当用户在软键盘上点击完成/搜索时触发
          onSubmitted: (value) {
            // 确保在 setState 前后访问 ref
            ref.read(searchQueryProvider.notifier).state = value;
            // 可选: 隐藏键盘
            FocusScope.of(context).unfocus();
          },
          // 实时更新搜索结果
          onChanged: (value) {
            // 简单实现：直接更新
            // 确保在 setState 前后访问 ref
            ref.read(searchQueryProvider.notifier).state = value;
            // 如果需要 debounce, 在这里调用 _updateSearchQuery();
          },
        ),
        actions: [
          // 清除按钮
          // 只有当输入框有内容时才显示清除按钮
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              tooltip: '清除',
              onPressed: () {
                // 确保在 setState 前后访问 ref
                ref.read(searchQueryProvider.notifier).state = '';
                // 确保在 mounted 状态下调用 clear
                if (mounted) {
                  _searchController.clear();
                  // onChanged 会自动触发 ref 更新，这里不需要再次设置 ref
                }
              },
            ),
        ],
      );
    } else {
      // --- 正常状态下的 AppBar ---
      return AppBar(
        title: Text(titleText),
        actions: [
          // 只在植物、宠物、提醒 Tab 显示搜索按钮
          if (currentTabIndex < 3)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: '搜索',
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isSearching = true;
                    // 进入搜索时不清空之前的搜索词（如果需要保留）
                    // _searchController.text = ref.read(searchQueryProvider);
                    // if(_searchController.text.isNotEmpty){
                    //    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
                    // }
                  });
                }
              },
            ),

          // --- 排序/筛选按钮 ---
          // 根据当前 Tab 动态显示按钮
          // 使用 Consumer Widget 包裹以获取最新的 ref 和状态

          // 植物列表排序 (示例)
          if (currentTabIndex == 0)
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(plantSortOptionProvider);
                return PopupMenuButton<PlantSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序方式',
                  onSelected: (PlantSortOption result) {
                    ref.read(plantSortOptionProvider.notifier).state = result;
                  },
                  itemBuilder:
                      (BuildContext context) =>
                          _buildPlantSortMenuItems(currentSortOption),
                );
              },
            ),

          // 宠物列表排序 (示例)
          if (currentTabIndex == 1)
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(petSortOptionProvider);
                return PopupMenuButton<PetSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序方式',
                  onSelected: (PetSortOption result) {
                    ref.read(petSortOptionProvider.notifier).state = result;
                  },
                  itemBuilder:
                      (BuildContext context) =>
                          _buildPetSortMenuItems(currentSortOption),
                );
              },
            ),

          // 提醒列表筛选和排序
          if (currentTabIndex == 2) ...[
            Consumer(
              builder: (context, ref, _) {
                final currentFilterOption = ref.watch(
                  reminderFilterOptionProvider,
                );
                return PopupMenuButton<ReminderFilterOption>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: '筛选',
                  onSelected: (ReminderFilterOption result) {
                    ref.read(reminderFilterOptionProvider.notifier).state =
                        result;
                  },
                  itemBuilder:
                      (BuildContext context) =>
                          _buildReminderFilterMenuItems(currentFilterOption),
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final currentSortOption = ref.watch(reminderSortOptionProvider);
                return PopupMenuButton<ReminderSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序方式',
                  onSelected: (ReminderSortOption result) {
                    ref.read(reminderSortOptionProvider.notifier).state =
                        result;
                  },
                  itemBuilder:
                      (BuildContext context) =>
                          _buildReminderSortMenuItems(currentSortOption),
                );
              },
            ),
          ],
        ],
      );
    }
  }

  // --- Helper methods to build menu items ---

  // 构建植物排序菜单项
  List<PopupMenuEntry<PlantSortOption>> _buildPlantSortMenuItems(
    PlantSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: PlantSortOption.nameAsc,
        checked: current == PlantSortOption.nameAsc,
        child: const Text('名称 A-Z'),
      ),
      CheckedPopupMenuItem(
        value: PlantSortOption.nameDesc,
        checked: current == PlantSortOption.nameDesc,
        child: const Text('名称 Z-A'),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PlantSortOption.dateAddedDesc,
        checked: current == PlantSortOption.dateAddedDesc,
        child: const Text('最近添加'),
      ),
      CheckedPopupMenuItem(
        value: PlantSortOption.dateAddedAsc,
        checked: current == PlantSortOption.dateAddedAsc,
        child: const Text('最早添加'),
      ),
    ];
  }

  // 构建宠物排序菜单项
  List<PopupMenuEntry<PetSortOption>> _buildPetSortMenuItems(
    PetSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: PetSortOption.nameAsc,
        checked: current == PetSortOption.nameAsc,
        child: const Text('名称 A-Z'),
      ),
      CheckedPopupMenuItem(
        value: PetSortOption.nameDesc,
        checked: current == PetSortOption.nameDesc,
        child: const Text('名称 Z-A'),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PetSortOption.birthDateAsc,
        checked: current == PetSortOption.birthDateAsc,
        child: const Text('生日 最早'),
      ),
      CheckedPopupMenuItem(
        value: PetSortOption.birthDateDesc,
        checked: current == PetSortOption.birthDateDesc,
        child: const Text('生日 最近'),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: PetSortOption.dateAddedDesc,
        checked: current == PetSortOption.dateAddedDesc,
        child: const Text('最近添加'),
      ),
      CheckedPopupMenuItem(
        value: PetSortOption.dateAddedAsc,
        checked: current == PetSortOption.dateAddedAsc,
        child: const Text('最早添加'),
      ),
    ];
  }

  // 构建提醒筛选菜单项
  List<PopupMenuEntry<ReminderFilterOption>> _buildReminderFilterMenuItems(
    ReminderFilterOption current,
  ) {
    return ReminderFilterOption.values.map((option) {
        String text;
        switch (option) {
          case ReminderFilterOption.activeOnly:
            text = '仅激活';
            break;
          case ReminderFilterOption.overdueOnly:
            text = '仅过期';
            break;
          case ReminderFilterOption.inactiveOnly:
            text = '仅暂停';
            break;
          case ReminderFilterOption.all:
            text = '显示全部';
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
      ); // 在 '显示全部' 前插入分隔符
  }

  // 构建提醒排序菜单项
  List<PopupMenuEntry<ReminderSortOption>> _buildReminderSortMenuItems(
    ReminderSortOption current,
  ) {
    return [
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateAsc,
        checked: current == ReminderSortOption.dueDateAsc,
        child: const Text('截止日期 最早'),
      ),
      CheckedPopupMenuItem(
        value: ReminderSortOption.dueDateDesc,
        checked: current == ReminderSortOption.dueDateDesc,
        child: const Text('截止日期 最近'),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameAsc,
        checked: current == ReminderSortOption.nameAsc,
        child: const Text('名称 A-Z'),
      ),
      CheckedPopupMenuItem(
        value: ReminderSortOption.nameDesc,
        checked: current == ReminderSortOption.nameDesc,
        child: const Text('名称 Z-A'),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedDesc,
        checked: current == ReminderSortOption.dateAddedDesc,
        child: const Text('最近添加'),
      ),
      CheckedPopupMenuItem(
        value: ReminderSortOption.dateAddedAsc,
        checked: current == ReminderSortOption.dateAddedAsc,
        child: const Text('最早添加'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // 使用动态构建的 AppBar
      body: PopScope(
        // 使用 PopScope 处理 Android 物理返回键退出搜索
        canPop: !_isSearching, // 如果在搜索模式，不允许默认返回
        onPopInvoked: (didPop) {
          if (didPop) {
            return; // 如果允许 pop，直接返回
          }
          if (_isSearching) {
            // 如果在搜索模式下阻止了 pop，则退出搜索模式
            // 确保在 setState 前后访问 ref
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = '';
            }
            // 确保在 mounted 状态下调用 setState
            if (mounted) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            }
          }
        },
        child: widget.navigationShell, // GoRouter 的子页面内容
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined),
            activeIcon: Icon(Icons.local_florist),
            label: '植物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: '宠物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: '提醒',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          // 切换 Tab 时退出搜索模式
          if (_isSearching) {
            // 确保在 setState 前后访问 ref
            final currentQuery = ref.read(searchQueryProvider);
            if (currentQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = '';
            }
            // 确保在 mounted 状态下调用 setState
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
        type: BottomNavigationBarType.fixed, // Or adaptive
        // Consider theme adjustments for selected/unselected colors
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Colors.grey,
      ),
    );
  }
}
