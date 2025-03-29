import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell; // GoRouter 传入的导航状态

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body 部分由 GoRouter 根据当前 tab 自动填充
      body: navigationShell,

      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined),
            activeIcon: Icon(Icons.local_florist), // 选中时的图标
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
          // 如果有设置页
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings_outlined),
          //   activeIcon: Icon(Icons.settings),
          //   label: '设置',
          // ),
        ],
        currentIndex: navigationShell.currentIndex, // 当前选中的 tab 索引
        onTap: (index) {
          // 点击 tab 时，切换页面
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed, // 固定样式，即使多于3个也显示文字
        // 主题中已配置颜色，这里可以不设置
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Colors.grey,
      ),
    );
  }
}
