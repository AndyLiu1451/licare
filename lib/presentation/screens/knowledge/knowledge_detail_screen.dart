import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // 根据类型选择正确的 Provider
    final asyncTopics = ref.watch(
      type == KnowledgeType.plant
          ? plantKnowledgeProvider
          : petKnowledgeProvider,
    );

    return Scaffold(
      appBar: AppBar(
        // AppBar 标题会动态设置
      ),
      body: asyncTopics.when(
        data: (topics) {
          // 从列表中找到对应的 Topic
          final topic = topics.firstWhere(
            (t) => t.id == topicId,
            orElse:
                () => KnowledgeTopic(
                  // Fallback if not found
                  id: '',
                  name: '未找到主题',
                  category: '',
                  sections: [],
                ),
          );

          if (topic.id.isEmpty) {
            return const Center(child: Text('无法加载主题内容'));
          }

          // 设置 AppBar 标题
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Safely update AppBar title after build
            if (context.mounted) {
              final appBar = Scaffold.of(context).widget.appBar as AppBar?;
              if (appBar != null && appBar.title is Text) {
                // This approach is tricky and might not work reliably.
                // A better way is to pass the title via GoRouter state or use a StateNotifier for the title.
                // For simplicity now, we assume AppBar is simple Text.
                // (appBar.title as Text).controller?.text = topic.name; // Not possible with Text widget
                // Consider using a Provider for the title
              }
            }
          });

          return CustomScrollView(
            // 使用 CustomScrollView 防止内容过多溢出
            slivers: [
              // 固定 AppBar，显示标题
              SliverAppBar(
                title: Text(topic.name), // 设置标题
                pinned: true, // 固定在顶部
                automaticallyImplyLeading: false, // 通常详情页有返回按钮，这里不再需要系统默认的
                backgroundColor:
                    Theme.of(context).appBarTheme.backgroundColor ??
                    Theme.of(context).colorScheme.surface, // 确保背景色
                elevation: Theme.of(context).appBarTheme.elevation ?? 2.0,
                // foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // Set foreground color if needed
              ),
              // 内容列表
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final section = topic.sections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.content,
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
        error: (error, stack) => Center(child: Text('加载知识详情失败: $error')),
      ),
    );
  }
}
