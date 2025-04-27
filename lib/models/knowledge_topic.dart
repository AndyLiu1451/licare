import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// 用于解析 JSON 中的 section
class KnowledgeSection {
  final String title;
  final String content;

  KnowledgeSection({required this.title, required this.content});

  factory KnowledgeSection.fromJson(Map<String, dynamic> json) {
    return KnowledgeSection(
      title: json['title'] as String? ?? '无标题', // 提供默认值
      content: json['content'] as String? ?? '无内容',
    );
  }
}

// 用于解析 JSON 中的主题条目
class KnowledgeTopic {
  final String id;
  final String name;
  final String category;
  final List<KnowledgeSection> sections;

  KnowledgeTopic({
    required this.id,
    required this.name,
    required this.category,
    required this.sections,
  });

  factory KnowledgeTopic.fromJson(Map<String, dynamic> json) {
    var sectionsFromJson = json['sections'] as List<dynamic>? ?? [];
    List<KnowledgeSection> sectionList =
        sectionsFromJson
            .map(
              (sectionJson) => KnowledgeSection.fromJson(
                sectionJson as Map<String, dynamic>,
              ),
            )
            .toList();

    return KnowledgeTopic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '未知主题',
      category: json['category'] as String? ?? '未分类',
      sections: sectionList,
    );
  }
}

// Helper function to load and parse knowledge data from asset JSON
Future<List<KnowledgeTopic>> loadKnowledgeTopics(String assetPath) async {
  try {
    final String jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (jsonItem) =>
              KnowledgeTopic.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  } catch (e) {
    print("Error loading or parsing knowledge topics from $assetPath: $e");
    return []; // Return empty list on error
  }
}

// Need to import rootBundle
