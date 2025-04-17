import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入 SharedPreferences
import 'package:plant_pet_log/config/router/app_router.dart';
import 'package:plant_pet_log/config/theme/app_theme.dart';
import 'package:plant_pet_log/services/notification_service.dart'; // 引入通知服务 (如果需要在此初始化)
import 'package:plant_pet_log/providers/theme_provider.dart'; // 引入主题相关 Provider

Future<void> main() async {
  // 1. main 函数改为 async
  WidgetsFlutterBinding.ensureInitialized(); // 2. 确保 Flutter 绑定已初始化

  // 3. 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 4. (可选) 初始化通知服务 - 注意 ProviderScope 的位置
  //    如果 NotificationService 内部需要读取 SharedPreferences，
  //    初始化需要发生在 ProviderScope 之后或使用 ProviderContainer。
  //    简单起见，先注释掉这里的初始化，可以在 MyApp 首次 build 时进行。
  // final container = ProviderContainer(overrides: [
  //   sharedPreferencesProvider.overrideWithValue(prefs),
  // ]);
  // await container.read(notificationServiceProvider).initialize();
  // container.dispose();

  // 5. 运行应用，包裹在 ProviderScope 中，并覆盖 SharedPreferences Provider
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MyApp(),
    ),
  );

  // 6. (可选) 应用启动后重新调度提醒
  //    这需要在 MyApp build 之后或有可用 context 时执行
  //    暂时注释掉，可在 MyApp 内部处理
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //    // 需要确保有 context 或使用全局 container
  //    // ProviderScope.containerOf(navigatorKey.currentContext!)
  //    //     .read(notificationServiceProvider)
  //    //     .rescheduleAllActiveReminders();
  // });
}

// 7. 定义全局 Navigator Key (如果 GoRouter 需要)
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  // 8. MyApp 改为 ConsumerWidget
  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 9. 添加 WidgetRef ref
    // 10. 监听主题状态
    final themeMode = ref.watch(
      themeNotifierProvider,
    ); // 获取 ThemeMode (system, light, dark)
    final selectedColorIndex = ref.watch(selectedColorIndexProvider); // 获取颜色索引

    // 11. 创建 AppTheme 实例
    final appTheme = AppTheme(selectedColor: selectedColorIndex);

    // 12. 获取 GoRouter 实例 (需要传入 navigatorKey)
    final goRouter = ref.watch(goRouterProvider(navigatorKey));

    // 13. (可选) 在这里初始化通知服务或执行 reschedule
    _initializeNotificationsOnce(ref); // 调用下面的辅助方法

    // 14. 返回 MaterialApp.router 并配置主题
    return MaterialApp.router(
      title: '植宠日志',
      debugShowCheckedModeBanner: false,

      // !! 配置主题 !!
      theme: appTheme.themeData(brightness: Brightness.light), // 设置浅色主题
      darkTheme: appTheme.themeData(brightness: Brightness.dark), // 设置深色主题
      themeMode: themeMode, // 根据状态设置主题模式

      routerConfig: goRouter, // 使用 GoRouter 进行路由
    );
  }

  // 辅助方法，确保通知服务只初始化一次
  // 注意：这是一种简单的处理方式，更复杂的场景可能需要专门的启动逻辑
  bool _notificationsInitialized = false;
  void _initializeNotificationsOnce(WidgetRef ref) {
    // 使用 WidgetsBinding 在 build 方法完成后安全地执行异步操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notificationsInitialized) {
        print("Initializing Notification Service...");
        // 使用 read 通常在回调或异步操作中更安全
        ref
            .read(notificationServiceProvider)
            .initialize()
            .then((_) {
              print("Notification Service Initialized.");
              // 初始化后可以重新调度提醒
              ref
                  .read(notificationServiceProvider)
                  .rescheduleAllActiveReminders();
            })
            .catchError((error) {
              print("Error initializing notification service: $error");
            });
        _notificationsInitialized = true;
      }
    });
  }
}

// 15. 确保 GoRouter Provider 定义接收 NavigatorKey (如果之前没有修改)
//    这个 Provider 通常在 lib/config/router/app_router.dart 中定义
// final goRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((ref, rootNavigatorKey) {
//    // ... GoRouter 配置 ...
//    return GoRouter(
//       navigatorKey: rootNavigatorKey,
//       // ... rest of config ...
//    );
// });
