import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/object_providers.dart';
import '../../widgets/pet_list_item.dart';
import '../../../providers/list_filter_providers.dart'; // !! 引入筛选/排序 Provider !! (如果排序按钮在这里)

class PetListScreen extends ConsumerWidget {
  static const routeName = 'petList';
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n 实例 !!
    final petListAsyncValue = ref.watch(petListStreamProvider);
    // final currentSortOption = ref.watch(petSortOptionProvider); // 如果排序按钮在这里，需要 watch

    // 注意：AppBar 通常在 MainScreen 中根据 Tab 动态设置，这里不再包含 AppBar

    return Stack(
      // 使用 Stack 来放置 FAB
      children: [
        petListAsyncValue.when(
          data: (pets) {
            if (pets.isEmpty) {
              // 空列表提示
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.noPets, // !! 使用 l10n.noPets !!
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            } else {
              // 宠物列表
              return ListView.builder(
                // Add padding to prevent FAB overlap if needed, or rely on Stack
                padding: const EdgeInsets.only(top: 8, bottom: 80), // 增加顶部和底部间距
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetListItem(pet: pet); // PetListItem 内部的文本也需要本地化
                },
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            print('Error loading pets: $error'); // Log error for debugging
            // 加载失败提示
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.loadingFailed(
                    error.toString(),
                  ), // !! 使用带占位符的 l10n.loadingFailed !!
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red), // Use error color
                ),
              ),
            );
          },
        ),
        // FloatingActionButton 保持在 Stack 底部
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag:
                'fab_pet_list', // Ensure unique heroTag if multiple FABs exist
            onPressed: () {
              context.goNamed('addPet');
            },
            tooltip: l10n.addPet, // !! 使用 l10n.addPet !!
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

// 注意: PetListItem Widget 内部的文本 (例如 Card/ListTile 中的内容)
// 如果包含硬编码字符串，也需要按照相同的方式进行本地化处理。
