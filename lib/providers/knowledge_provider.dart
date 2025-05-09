import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/providers/database_provider.dart';
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

// Provider for all event types (preset and custom)
final allEventTypesStreamProvider =
    StreamProvider.autoDispose<List<CustomEventType>>((ref) {
      final db = ref.watch(databaseProvider);
      return db.watchAllEventTypes();
    });

// Provider to get icon data for a specific event type name (caches result)
// Use FutureProvider + family for efficient caching
final eventTypeIconProvider = FutureProvider.autoDispose
    .family<TypedIconData, String>((ref, eventTypeName) async {
      final db = ref.read(databaseProvider); // Use read for potential caching
      final iconData = await db.getIconForEventType(eventTypeName);
      // Return default if null to avoid errors in UI
      return iconData ?? TypedIconData(Icons.label_outline); // Fallback icon
    });
