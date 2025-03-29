import 'dart:io'; // 用于 File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // 引入 intl
import '../../../data/local/database/app_database.dart'; // 引入数据库类
import '../../../models/enum.dart';
import '../../../providers/object_providers.dart'; // 引入 Providers
import '../../widgets/log_list_item.dart'; // !! 稍后创建日志列表项 Widget
import '../../widgets/add_log_dialog.dart';

class DetailsScreen extends ConsumerWidget {
  // 1. 改为 ConsumerWidget
  final int objectId;
  final ObjectType objectType;

  const DetailsScreen({
    super.key,
    required this.objectId,
    required this.objectType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 添加 WidgetRef ref
    final String titlePrefix = objectType == ObjectType.plant ? '植物' : '宠物';
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    // 3. 根据 objectType 监听对应的详情 Provider
    final detailsAsyncValue =
        objectType == ObjectType.plant
            ? ref.watch(plantDetailsProvider(objectId))
            : ref.watch(petDetailsProvider(objectId));

    // 4. 监听对应的日志列表 Provider
    final logAsyncValue =
        objectType == ObjectType.plant
            ? ref.watch(plantLogStreamProvider(objectId))
            : ref.watch(petLogStreamProvider(objectId));

    // 5. 监听对应的提醒列表 Provider (可选，也可以在专门的提醒管理区域显示)
    // final remindersAsyncValue = ref.watch(objectRemindersStreamProvider((objectId: objectId, objectType: objectType)));

    return Scaffold(
      // 6. 使用 AsyncValue.when 处理详情数据的加载状态
      body: detailsAsyncValue.when(
        data: (objectData) {
          // 数据加载成功，但对象可能已被删除 (null)
          if (objectData == null) {
            return const Center(child: Text('对象不存在或已被删除'));
          }

          // 根据类型确定具体对象 (Plant or Pet)
          String name = '';
          String? nickname;
          String? photoPath;
          Widget specificDetails; // 用于显示植物或宠物特有的信息

          if (objectType == ObjectType.plant && objectData is Plant) {
            name = objectData.name;
            nickname = objectData.nickname;
            photoPath = objectData.photoPath;
            specificDetails = _buildPlantSpecificDetails(
              context,
              objectData,
              dateFormatter,
            );
          } else if (objectType == ObjectType.pet && objectData is Pet) {
            name = objectData.name;
            nickname = objectData.nickname;
            photoPath = objectData.photoPath;
            specificDetails = _buildPetSpecificDetails(
              context,
              objectData,
              dateFormatter,
            );
          } else {
            return const Center(child: Text('数据类型错误')); // 不应该发生
          }

          // 使用 CustomScrollView 实现带伸缩 AppBar 的效果
          return CustomScrollView(
            slivers: <Widget>[
              // 7. 伸缩 AppBar
              SliverAppBar(
                expandedHeight: 250.0, // AppBar 展开的高度
                floating: false, // 向下滚动时AppBar是否立即出现
                pinned: true, // AppBar 是否固定在顶部
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    name, // 在收起时显示名字
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      shadows: <Shadow>[
                        // 给文字加点阴影，防止背景太亮看不清
                        Shadow(
                          offset: Offset(0.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  background:
                      photoPath != null && File(photoPath).existsSync()
                          ? Image.file(
                            // 显示对象图片作为背景
                            File(photoPath),
                            fit: BoxFit.cover, // 图片覆盖整个区域
                            // 添加一层遮罩让标题更清晰
                            colorBlendMode: BlendMode.darken,
                            color: Colors.black.withOpacity(0.3),
                          )
                          : Container(
                            // 如果没有图片，显示占位颜色和图标
                            color: Theme.of(context).primaryColor,
                            child: Icon(
                              objectType == ObjectType.plant
                                  ? Icons.local_florist
                                  : Icons.pets,
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                ),
                actions: [
                  // 编辑按钮
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                    onPressed: () {
                      if (objectType == ObjectType.plant) {
                        context.goNamed(
                          'editPlant',
                          pathParameters: {'id': objectId.toString()},
                        );
                      } else {
                        context.goNamed(
                          'editPet',
                          pathParameters: {'id': objectId.toString()},
                        );
                      }
                    },
                  ),
                ],
              ),
              // 8. 对象的基本信息和特定信息
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nickname != null && nickname.isNotEmpty)
                        Text(
                          nickname,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (nickname != null && nickname.isNotEmpty)
                        const SizedBox(height: 8),
                      specificDetails, // 显示植物/宠物特有信息
                      const Divider(height: 32), // 分隔线
                      Text(
                        '日志记录',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              // 9. 显示日志列表 (使用 AsyncValue.when 处理加载)
              logAsyncValue.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const SliverToBoxAdapter(
                      // 如果日志为空，显示提示
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('还没有日志记录')),
                      ),
                    );
                  }
                  // 如果日志不为空，使用 SliverList 显示
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final log = logs[index];
                      // TODO: 创建并使用 LogListItem Widget
                      return LogListItem(logEntry: log);
                    }, childCount: logs.length),
                  );
                },
                loading:
                    () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                error:
                    (error, stack) => SliverToBoxAdapter(
                      child: Center(child: Text('加载日志失败: $error')),
                    ),
              ),
              // 添加一些底部空间
              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // 确保 FAB 不会遮挡最后一个列表项
              ),
            ],
          );
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ), // 详情加载中
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('加载详情失败: $error'))), // 详情加载失败
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现添加日志条目的功能 (可能弹出对话框或新页面)
          _showAddLogDialog(context, ref, objectId, objectType); // 调用显示对话框的方法
          // 或者跳转页面: context.pushNamed('addLog', pathParameters: ...);
        },
        tooltip: '添加日志',
        child: const Icon(Icons.note_add),
      ),
    );
  }

  // --- Helper Widgets ---

  // 10. 构建植物特定信息 Widget
  Widget _buildPlantSpecificDetails(
    BuildContext context,
    Plant plant,
    DateFormat formatter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plant.species != null && plant.species!.isNotEmpty)
          _buildInfoRow(context, Icons.eco_outlined, '品种', plant.species!),
        if (plant.acquisitionDate != null)
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            '获取日期',
            formatter.format(plant.acquisitionDate!),
          ),
        if (plant.room != null && plant.room!.isNotEmpty)
          _buildInfoRow(context, Icons.location_on_outlined, '位置', plant.room!),
        _buildInfoRow(
          context,
          Icons.access_time,
          '添加于',
          formatter.format(plant.creationDate),
        ),
      ],
    );
  }

  // 11. 构建宠物特定信息 Widget
  Widget _buildPetSpecificDetails(
    BuildContext context,
    Pet pet,
    DateFormat formatter,
  ) {
    String genderText;
    switch (pet.gender) {
      case Gender.male:
        genderText = '雄性';
        break;
      case Gender.female:
        genderText = '雌性';
        break;
      default:
        genderText = '未知';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pet.species != null && pet.species!.isNotEmpty)
          _buildInfoRow(context, Icons.category_outlined, '种类', pet.species!),
        if (pet.breed != null && pet.breed!.isNotEmpty)
          _buildInfoRow(context, Icons.pets, '品种', pet.breed!),
        if (pet.birthDate != null)
          _buildInfoRow(
            context,
            Icons.cake_outlined,
            '生日',
            formatter.format(pet.birthDate!),
          ),
        if (pet.gender != null)
          _buildInfoRow(
            context,
            pet.gender == Gender.male
                ? Icons.male
                : (pet.gender == Gender.female
                    ? Icons.female
                    : Icons.question_mark),
            '性别',
            genderText,
          ),
        _buildInfoRow(
          context,
          Icons.access_time,
          '添加于',
          formatter.format(pet.creationDate),
        ),
      ],
    );
  }

  // 12. 构建信息行 Widget (用于复用)
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  // 13. 显示添加日志对话框的方法 (稍后实现具体内容)
  void _showAddLogDialog(
    BuildContext context,
    WidgetRef ref,
    int objectId,
    ObjectType objectType,
  ) {
    showDialog<bool>(
      // 修改返回类型为 bool?
      context: context,
      // barrierDismissible: false, // 可以阻止点击外部关闭对话框，强制用户操作
      builder: (BuildContext context) {
        // 使用我们创建的 AddLogDialog Widget
        return AddLogDialog(objectId: objectId, objectType: objectType);
      },
    ).then((success) {
      // 对话框关闭后，检查是否成功保存
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日志记录已添加'),
            duration: Duration(seconds: 2),
          ),
        );
        // 无需手动刷新列表，因为我们使用的是 StreamProvider，
        // 数据库更新后会自动触发 UI 更新。
      }
    });
  }
}
