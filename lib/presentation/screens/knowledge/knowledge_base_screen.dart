// lib/presentation/screens/knowledge/knowledge_base_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/knowledge_topic.dart';
import '../../../providers/knowledge_provider.dart';

class KnowledgeBaseScreen extends ConsumerWidget {
  static const routeName = 'knowledgeBase';
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // 如果无法 pop (例如直接打开了 /knowledge)，可以导航到主页或设置页
                context.go('/settings'); // 或者 context.go('/')
              }
            },
          ),
          title: const Text('养护知识库'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '植物知识', icon: Icon(Icons.local_florist_outlined)),
              Tab(text: '宠物知识', icon: Icon(Icons.pets_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 调用 _buildTopicList 时传递具体的 autoDispose provider
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

  // 构建主题列表的通用方法
  Widget _buildTopicList(
    BuildContext context,
    WidgetRef ref,
    // !! 修改参数类型 !!
    // 从 FutureProvider<List<KnowledgeTopic>> 改为
    // ProviderListenable<AsyncValue<List<KnowledgeTopic>>>
    // 这个类型包含了 FutureProvider, StreamProvider, StateProvider 等返回 AsyncValue 的 Provider
    ProviderListenable<AsyncValue<List<KnowledgeTopic>>> provider,
    KnowledgeType topicType, // 修改变量名以便区分
  ) {
    // watch 的用法保持不变，它能正确处理 ProviderListenable
    final asyncData = ref.watch(provider);

    return asyncData.when(
      data: (topics) {
        if (topics.isEmpty) {
          return const Center(child: Text('暂无知识内容'));
        }
        return ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return ListTile(
              title: Text(topic.name),
              subtitle: Text(topic.category),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.goNamed(
                  'knowledgeDetail',
                  pathParameters: {'topicId': topic.id},
                  // 传递类型给详情页
                  extra: topicType,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载知识失败: $error')),
    );
  }
}

// 枚举用于传递类型给详情页
enum KnowledgeType { plant, pet }
