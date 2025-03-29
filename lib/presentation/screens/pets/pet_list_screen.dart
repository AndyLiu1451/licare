import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import '../../../providers/object_providers.dart'; // 引入 Provider
import '../../widgets/pet_list_item.dart'; // 引入列表项 Widget
import '../../../models/enum.dart';

class PetListScreen extends ConsumerWidget {
  // 1. 改为 ConsumerWidget
  static const routeName = 'petList';
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 添加 WidgetRef ref
    // 3. 监听宠物列表流 Provider
    final petListAsyncValue = ref.watch(petListStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的宠物')),
      // 4. 处理 AsyncValue 状态
      body: petListAsyncValue.when(
        data: (pets) {
          if (pets.isEmpty) {
            return const Center(
              child: Text(
                '还没有添加宠物哦，\n点击右下角按钮添加一个吧！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return PetListItem(pet: pet); // 使用列表项 Widget
              },
            );
          }
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          print('Error loading pets: $error');
          return Center(child: Text('加载失败: ${error.toString()}'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('addPet');
        },
        tooltip: '添加宠物',
        child: const Icon(Icons.add),
      ),
    );
  }
}
