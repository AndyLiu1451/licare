import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import '../../../providers/object_providers.dart'; // 引入我们创建的 Provider
import '../../widgets/plant_list_item.dart'; // 引入列表项 Widget
import '../../../models/enum.dart'; // 如果需要，引入枚举

class PlantListScreen extends ConsumerWidget {
  // 1. 改为 ConsumerWidget
  static const routeName = 'plantList';
  const PlantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 添加 WidgetRef ref
    // 3. 监听植物列表流 Provider
    final plantListAsyncValue = ref.watch(plantListStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的植物')),
      // 4. 使用 AsyncValue 的 when 方法来处理不同状态
      body: plantListAsyncValue.when(
        data: (plants) {
          // 数据加载成功
          if (plants.isEmpty) {
            // 列表为空，显示提示信息
            return const Center(
              child: Text(
                '还没有添加植物哦，\n点击右下角按钮添加一个吧！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            // 列表不为空，使用 ListView.builder 显示
            return ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return PlantListItem(plant: plant); // 使用列表项 Widget
              },
            );
          }
        },
        loading: () {
          // 加载中状态，显示进度指示器
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          // 发生错误，显示错误信息
          print('Error loading plants: $error'); // 在控制台打印错误方便调试
          return Center(child: Text('加载失败: ${error.toString()}'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('addPlant');
        },
        tooltip: '添加植物',
        child: const Icon(Icons.add),
      ),
    );
  }
}
