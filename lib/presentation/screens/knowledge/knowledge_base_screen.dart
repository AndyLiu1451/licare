// lib/presentation/screens/knowledge/knowledge_base_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/knowledge_topic.dart';
import '../../../providers/knowledge_provider.dart';

class KnowledgeBaseScreen extends ConsumerWidget {
  static const routeName = 'knowledgeBase';
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 2. 获取 l10n 实例 !!

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // leading 部分保持不变 (通常不需要本地化返回按钮图标)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
          ),
          // !! 3. 使用 l10n 替换 AppBar 标题 !!
          title: Text(l10n.knowledgeBase),
          bottom: TabBar(
            tabs: [
              // !! 4. 使用 l10n 替换 Tab 文本 !!
              Tab(
                text: l10n.plantKnowledge,
                icon: const Icon(Icons.local_florist_outlined),
              ),
              Tab(
                text: l10n.petKnowledge,
                icon: const Icon(Icons.pets_outlined),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTopicList(
              context,
              ref,
              plantKnowledgeProvider,
              KnowledgeType.plant,
            ),
            _buildTopicList(
              context,
              ref,
              petKnowledgeProvider,
              KnowledgeType.pet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicList(
    BuildContext context,
    WidgetRef ref,
    ProviderListenable<AsyncValue<List<KnowledgeTopic>>> provider,
    KnowledgeType topicType,
  ) {
    final l10n = AppLocalizations.of(context)!; // !! 5. 在子方法中也获取 l10n !!
    final asyncData = ref.watch(provider);

    return asyncData.when(
      data: (topics) {
        if (topics.isEmpty) {
          // !! 6. 使用 l10n 替换空状态文本 !!
          return Center(child: Text(l10n.noKnowledge));
        }
        return ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return ListTile(
              // topic.name 和 topic.category 通常来自 JSON 数据，
              // 如果 JSON 数据本身就是目标语言，则无需翻译。
              // 如果 JSON 数据是固定语言（如英文），而你需要根据应用语言显示翻译，
              // 则需要更复杂的逻辑，例如在 KnowledgeTopic 模型或 Provider 中处理翻译。
              // 这里我们假设 topic.name 和 topic.category 是可以直接显示的。
              title: Text(topic.name),
              subtitle: Text(topic.category),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.goNamed(
                  'knowledgeDetail',
                  pathParameters: {'topicId': topic.id},
                  extra: topicType,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // !! 7. 使用带占位符的 l10n 替换错误文本 !!
        return Center(
          child: Text(l10n.loadingKnowledgeFailed(error.toString())),
        );
      },
    );
  }
}

// 枚举用于传递类型给详情页 (保持不变)
enum KnowledgeType { plant, pet }
