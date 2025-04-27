import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/knowledge_topic.dart'; // 引入模型和加载函数

// Provider for Plant knowledge topics
final plantKnowledgeProvider = FutureProvider.autoDispose<List<KnowledgeTopic>>(
  (ref) async {
    return loadKnowledgeTopics('assets/knowledge_base/plants_knowledge.json');
  },
);

// Provider for Pet knowledge topics
final petKnowledgeProvider = FutureProvider.autoDispose<List<KnowledgeTopic>>((
  ref,
) async {
  return loadKnowledgeTopics('assets/knowledge_base/pets_knowledge.json');
});

// (可选) Provider for currently selected topic ID for detail view
final selectedKnowledgeTopicIdProvider = StateProvider<String?>((ref) => null);
