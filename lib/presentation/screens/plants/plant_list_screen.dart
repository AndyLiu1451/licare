import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import '../../../providers/object_providers.dart'; // 引入我们创建的 Provider
import '../../widgets/plant_list_item.dart'; // 引入列表项 Widget
import '../../../l10n/app_localizations.dart';

class PlantListScreen extends ConsumerWidget {
  // 1. 改为 ConsumerWidget
  static const routeName = 'plantList';
  const PlantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 添加 WidgetRef ref
    // 3. 监听植物列表流 Provider
    // 监听列表数据 (现在它会自动根据排序状态更新)
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final plantListAsyncValue = ref.watch(plantListStreamProvider);
    // 获取当前的排序选项，用于显示或更新

    return Stack(
      // 使用 Stack 将 FAB 放置在列表之上
      children: [
        plantListAsyncValue.when(
          data: (plants) {
            if (plants.isEmpty) {
              return Center(
                child: Padding(
                  // 添加 Padding 增加舒适度
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.noPlants,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ), // 增加底部 padding 防止 FAB 遮挡
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return PlantListItem(plant: plant);
                },
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Padding(
                  // 添加 Padding
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.loadingFailed(error.toString()),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
        // 将 FAB 放置在 Stack 的右下角
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'fab_plant_list', // 为每个 FAB 提供唯一 Tag
            onPressed: () {
              context.goNamed('addPlant');
            },
            tooltip: l10n.addPlant,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
