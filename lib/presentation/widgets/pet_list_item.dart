import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/database/app_database.dart'; // 引入 Pet 类
import '../../models/enum.dart'; // 引入 ObjectType

class PetListItem extends StatelessWidget {
  final Pet pet;

  const PetListItem({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: 未来加载 pet.photoPath 图片
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.pets_outlined,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(pet.name, style: theme.textTheme.titleMedium),
        subtitle:
            pet.nickname != null && pet.nickname!.isNotEmpty
                ? Text(pet.nickname!)
                : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 点击跳转到宠物详情页
          context.goNamed(
            'petDetails',
            pathParameters: {'id': pet.id.toString()},
          );
        },
      ),
    );
  }
}
