import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/database/app_database.dart'; // 引入 Plant 类
import '../../models/enum.dart'; // 引入 ObjectType

class PlantListItem extends StatelessWidget {
  final Plant plant;

  const PlantListItem({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // 使用 Card 增加视觉分隔
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          // 显示一个占位符或缩略图
          // TODO: 未来加载 plant.photoPath 图片
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.local_florist_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(plant.name, style: theme.textTheme.titleMedium),
        subtitle:
            plant.nickname != null && plant.nickname!.isNotEmpty
                ? Text(plant.nickname!)
                : null,
        trailing: const Icon(Icons.chevron_right), // 指示可点击
        onTap: () {
          // 点击跳转到植物详情页
          context.goNamed(
            'plantDetails',
            pathParameters: {'id': plant.id.toString()},
          );
        },
      ),
    );
  }
}
