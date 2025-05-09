import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/photo_info.dart';
// !! 1. 引入 AppLocalizations !!
import '../../../l10n/app_localizations.dart';
// Optional: Import interactive_viewer for zoom/pan
// import 'package:interactive_viewer_gallery/interactive_viewer_gallery.dart';

class PhotoComparisonScreen extends StatelessWidget {
  static const routeName = 'photoComparison';
  final PhotoInfo photo1;
  final PhotoInfo photo2;
  final String objectName;

  const PhotoComparisonScreen({
    super.key,
    required this.photo1,
    required this.photo2,
    required this.objectName,
  });

  @override
  Widget build(BuildContext context) {
    // !! 2. 获取 l10n 实例 !!
    final l10n = AppLocalizations.of(context)!;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // !! 3. 修改 AppBar 标题 !!
        // 注意： l10n.growthComparison 可能需要添加 objectName 作为占位符
        // 如果 arb 文件定义为 "growthComparison": "{objectName} - 成长对比"
        // 则调用 l10n.growthComparison(objectName)
        // 如果 arb 文件定义为 "growthComparison": "成长对比"
        // 则拼接字符串如下：
        title: Text('$objectName - ${l10n.growthComparison}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Photo
                Expanded(
                  child: _buildComparisonItem(
                    context, // 传递 context
                    l10n, // 传递 l10n
                    photo1,
                    formatter,
                    theme,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1), // Separator
                // Right Photo
                Expanded(
                  child: _buildComparisonItem(
                    context, // 传递 context
                    l10n, // 传递 l10n
                    photo2,
                    formatter,
                    theme,
                  ),
                ),
              ],
            ),
          ),
          // ... (Optional Slider) ...
        ],
      ),
    );
  }

  // Helper widget to build one side of the comparison
  Widget _buildComparisonItem(
    BuildContext context, // 添加 context 参数
    AppLocalizations l10n, // 添加 l10n 参数
    PhotoInfo photo,
    DateFormat formatter,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formatter.format(photo.dateTaken),
            style: theme.textTheme.titleMedium,
          ),
          // 如果 logEventType 也需要本地化（例如从数据库读取的 "浇水" 需要显示为 "Watering"），
          // 你需要一个映射或更好的方式来处理。目前假设直接显示数据库中的字符串。
          if (photo.sourceType == PhotoSourceType.logEntry &&
              photo.logEventType != null)
            Text(photo.logEventType!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(photo.filePath),
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(height: 4),
                          // !! 4. 修改图片加载失败提示 !!
                          // 假设 arb 文件中有 "errorLoadingImage": "无法加载图片"
                          Text(
                            l10n.errorLoadingImage, // <-- 使用 l10n
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            // ... (Optional InteractiveViewer) ...
          ),
        ],
      ),
    );
  }
}
