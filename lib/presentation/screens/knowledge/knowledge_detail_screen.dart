// lib/presentation/screens/knowledge/knowledge_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/knowledge_topic.dart';
import '../../../providers/knowledge_provider.dart';
import 'knowledge_base_screen.dart'; // 引入 KnowledgeType 枚举

class KnowledgeDetailScreen extends ConsumerWidget {
  static const routeName = 'knowledgeDetail';
  final String topicId;
  final KnowledgeType type; // 接收类型

  const KnowledgeDetailScreen({
    super.key,
    required this.topicId,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n 实例 !!

    // 根据类型选择正确的 Provider
    final asyncTopics = ref.watch(
      type == KnowledgeType.plant
          ? plantKnowledgeProvider
          : petKnowledgeProvider,
    );

    // !! 不再需要在 build 方法外部设置 AppBar，因为有 SliverAppBar !!
    // return Scaffold(
    //   appBar: AppBar(), // 移除外部 AppBar
    //   body: ...
    // );
    // 直接返回 Scaffold，让 CustomScrollView 处理 AppBar
    return Scaffold(
      body: asyncTopics.when(
        data: (topics) {
          // 从列表中找到对应的 Topic
          final topic = topics.firstWhere(
            (t) => t.id == topicId,
            orElse:
                () => KnowledgeTopic(
                  // Fallback if not found
                  id: '',
                  name: l10n.topicNotFound, // !! 使用 l10n !!
                  category: '',
                  sections: [],
                ),
          );

          if (topic.id.isEmpty) {
            // 使用 l10n 替换硬编码字符串
            return Center(child: Text(l10n.topicNotFound)); // !! 使用 l10n !!
          }

          // !! 移除 WidgetsBinding.instance.addPostFrameCallback 来设置标题 !!
          // AppBar 标题现在由 SliverAppBar 处理

          return CustomScrollView(
            // 使用 CustomScrollView 防止内容过多溢出
            slivers: [
              // 固定 AppBar，显示标题 (标题来自 topic.name，是数据，不需要 l10n)
              SliverAppBar(
                title: Text(topic.name), // 设置标题 (来自数据)
                pinned: true, // 固定在顶部
                // automaticallyImplyLeading: false, // 保留默认值 true，显示返回按钮
                backgroundColor:
                    Theme.of(context).appBarTheme.backgroundColor ??
                    Theme.of(context).colorScheme.surface, // 确保背景色
                elevation: Theme.of(context).appBarTheme.elevation ?? 2.0,
              ),
              // 内容列表
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final section = topic.sections[index];
                    // section.title 和 section.content 来自 JSON 数据，不需要 l10n
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title, // 来自数据
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.content, // 来自数据
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(height: 1.5), // 增加行高
                          ),
                        ],
                      ),
                    );
                  }, childCount: topic.sections.length),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // 使用 l10n 替换硬编码字符串，并传入 error 参数
        error:
            (error, stack) => Center(
              child: Text(l10n.loadingKnowledgeFailed(error.toString())),
            ), // !! 使用 l10n !!
      ),
    );
  }
}
