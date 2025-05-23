// lib/config/router/app_router.dart (示例结构)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/models/photo_info.dart';
import 'package:plant_pet_log/presentation/screens/gallery/photo_comparison_screen.dart';
import 'package:plant_pet_log/presentation/screens/gallery/photo_gallery_screen.dart';
import 'package:plant_pet_log/presentation/screens/settings/manage_event_types_screen.dart';
// ... 引入你的屏幕文件 ...
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/plants/plant_list_screen.dart';
import '../../presentation/screens/pets/pet_list_screen.dart';
import '../../presentation/screens/reminders/reminders_list_screen.dart';
import '../../presentation/screens/details/details_screen.dart';
import '../../presentation/screens/add_edit/add_edit_object_screen.dart';
import '../../presentation/screens/add_edit/add_edit_reminder_screen.dart'; // 引入提醒编辑页
import '../../models/enum.dart'; // 引入枚举
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/knowledge/knowledge_base_screen.dart';
import '../../presentation/screens/knowledge/knowledge_detail_screen.dart';

// 使用 Provider.family 接收 GlobalKey<NavigatorState>
final goRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((
  ref,
  rootNavigatorKey,
) {
  // Key for shell navigator (通常不需要外部访问)
  // final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey, // 使用传入的 key
    initialLocation: '/plants', // 默认显示的页面
    // !! 将 routes 列表放在这里 !!
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // 植物 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plants',
                name: PlantListScreen.routeName,
                builder: (context, state) => const PlantListScreen(),
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    name: 'plantDetails',
                    builder:
                        (context, state) => DetailsScreen(
                          objectId: int.parse(state.pathParameters['id']!),
                          objectType: ObjectType.plant,
                        ),
                  ),
                  GoRoute(
                    path: 'gallery',
                    name: 'plantGallery',
                    builder: (context, state) {
                      // !! 修改点：从 extra 获取 ID 和 name !!
                      final extraData = state.extra as Map<String, dynamic>?;
                      if (extraData == null ||
                          extraData['objectId'] is! int ||
                          extraData['objectName'] is! String) {
                        // Handle error: Invalid or missing extra data
                        return const Scaffold(
                          body: Center(child: Text('错误：无法加载照片库数据')),
                        );
                      }
                      final objectId = extraData['objectId'] as int;
                      final objectName = extraData['objectName'] as String;

                      return PhotoGalleryScreen(
                        objectId: objectId,
                        objectType: ObjectType.plant,
                        objectName: objectName,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add',
                    name: 'addPlant',
                    builder:
                        (context, state) => const AddEditObjectScreen(
                          objectType: ObjectType.plant,
                        ),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'editPlant',
                    builder:
                        (context, state) => AddEditObjectScreen(
                          objectType: ObjectType.plant,
                          objectId: int.parse(state.pathParameters['id']!),
                        ),
                  ),
                ],
              ),
            ],
          ),
          // 宠物 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pets',
                name: PetListScreen.routeName,
                builder: (context, state) => const PetListScreen(),
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    name: 'petDetails',
                    builder:
                        (context, state) => DetailsScreen(
                          objectId: int.parse(state.pathParameters['id']!),
                          objectType: ObjectType.pet,
                        ),
                  ),
                  GoRoute(
                    path: 'gallery',
                    name: 'petGallery',
                    builder: (context, state) {
                      // !! 修改点：从 extra 获取 ID 和 name !!
                      final extraData = state.extra as Map<String, dynamic>?;
                      if (extraData == null ||
                          extraData['objectId'] is! int ||
                          extraData['objectName'] is! String) {
                        return const Scaffold(
                          body: Center(child: Text('错误：无法加载照片库数据')),
                        );
                      }
                      final objectId = extraData['objectId'] as int;
                      final objectName = extraData['objectName'] as String;

                      return PhotoGalleryScreen(
                        objectId: objectId,
                        objectType: ObjectType.pet,
                        objectName: objectName,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add',
                    name: 'addPet',
                    builder:
                        (context, state) => const AddEditObjectScreen(
                          objectType: ObjectType.pet,
                        ),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'editPet',
                    builder:
                        (context, state) => AddEditObjectScreen(
                          objectType: ObjectType.pet,
                          objectId: int.parse(state.pathParameters['id']!),
                        ),
                  ),
                ],
              ),
            ],
          ),
          // 提醒 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reminders',
                name: RemindersListScreen.routeName,
                builder: (context, state) => const RemindersListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'addReminder',
                    parentNavigatorKey: rootNavigatorKey, // 使用父导航器
                    builder: (context, state) => const AddEditReminderScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'editReminder',
                    parentNavigatorKey: rootNavigatorKey, // 使用父导航器
                    builder: (context, state) {
                      final reminderId = int.parse(state.pathParameters['id']!);
                      return AddEditReminderScreen(reminderId: reminderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: SettingsScreen.routeName, // 使用之前定义的 routeName
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  // !! 添加子路由 !!
                  GoRoute(
                    path: 'manage-event-types',
                    name: ManageEventTypesScreen.routeName,
                    builder: (context, state) => const ManageEventTypesScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ... 其他 branches ...
        ],
      ),
      GoRoute(
        path: '/knowledge', // 主路径
        name: KnowledgeBaseScreen.routeName,
        builder: (context, state) => const KnowledgeBaseScreen(),
        routes: [
          // 详情页子路由
          GoRoute(
            path: 'detail/:topicId', // 使用路径参数
            name: KnowledgeDetailScreen.routeName,
            builder: (context, state) {
              final topicId = state.pathParameters['topicId'] ?? '';
              // 获取从 extra 传递过来的类型
              final type =
                  state.extra as KnowledgeType? ??
                  KnowledgeType.plant; // Default or handle error
              return KnowledgeDetailScreen(topicId: topicId, type: type);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/photo-comparison',
        name: PhotoComparisonScreen.routeName,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data != null &&
              data['photo1'] is PhotoInfo &&
              data['photo2'] is PhotoInfo &&
              data['objectName'] is String) {
            return PhotoComparisonScreen(
              photo1: data['photo1'] as PhotoInfo,
              photo2: data['photo2'] as PhotoInfo,
              objectName: data['objectName'] as String,
            );
          } else {
            // Handle error - maybe navigate back or show error page
            return const Scaffold(body: Center(child: Text('无法加载对比照片')));
          }
        },
      ),
      // ... 其他顶层路由 ...
    ],

    // 可选: 错误处理等其他配置
    errorBuilder:
        (context, state) => Scaffold(
          // 添加错误页面方便调试
          appBar: AppBar(title: const Text('路由错误')),
          body: Center(
            child: Text(
              '页面未找到或路由错误: ${state.error?.message ?? state.uri.toString()}',
            ),
          ),
        ),
    // ... 其他 GoRouter 配置 ...
  );
});
