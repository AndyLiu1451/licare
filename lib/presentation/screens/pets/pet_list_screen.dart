import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import '../../../providers/object_providers.dart'; // 引入 Provider
import '../../widgets/pet_list_item.dart'; // 引入列表项 Widget

class PetListScreen extends ConsumerWidget {
  // 1. 改为 ConsumerWidget
  static const routeName = 'petList';
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 添加 WidgetRef ref
    // 3. 监听宠物列表流 Provider
    final petListAsyncValue = ref.watch(petListStreamProvider);

    return Stack(
      children: [
        petListAsyncValue.when(
          data: (pets) {
            if (pets.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '还没有添加宠物哦，\n点击右下角按钮添加一个吧！',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetListItem(pet: pet);
                },
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('加载失败: $error', textAlign: TextAlign.center),
                ),
              ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'fab_pet_list',
            onPressed: () {
              context.goNamed('addPet');
            },
            tooltip: '添加宠物',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
