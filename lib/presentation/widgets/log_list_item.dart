// lib/presentation/widgets/log_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/local/database/app_database.dart'; // 引入 LogEntry
import 'dart:convert'; // 用于解码 photoPaths
import 'dart:io'; // 用于 File

class LogListItem extends StatelessWidget {
  final LogEntry logEntry;

  const LogListItem({super.key, required this.logEntry});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
    final theme = Theme.of(context);

    // 解析照片路径 (假设存储的是 JSON 列表字符串)
    List<String> photoPaths = [];
    if (logEntry.photoPaths != null && logEntry.photoPaths!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(logEntry.photoPaths!);
        photoPaths = decoded.cast<String>();
      } catch (e) {
        print('Error decoding photoPaths: $e');
        // 处理解码错误，例如显示一个默认图标或错误提示
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 事件类型 (可以根据类型显示不同图标)
                Row(
                  children: [
                    _getEventTypeIcon(logEntry.eventType), // 获取事件图标
                    const SizedBox(width: 8),
                    Text(
                      logEntry.eventType, // 显示事件类型文字
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 事件时间
                Text(
                  dateTimeFormatter.format(logEntry.eventDateTime),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            // 备注内容
            if (logEntry.notes != null && logEntry.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32.0), // 与图标对齐
                child: Text(logEntry.notes!),
              ),
            // 显示图片缩略图
            if (photoPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32.0),
                child: SizedBox(
                  height: 60, // 固定高度
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoPaths.length,
                    itemBuilder: (context, index) {
                      final path = photoPaths[index];
                      // TODO: 点击缩略图可以放大查看
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(
                          File(path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          // 添加错误处理
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            // TODO: 添加编辑和删除日志条目的按钮 (例如使用 PopupMenuButton 或 IconButton)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [ IconButton(...) ],
            // ),
          ],
        ),
      ),
    );
  }

  // Helper function to get an icon based on event type
  Widget _getEventTypeIcon(String eventType) {
    IconData iconData;
    // 这里可以根据你的具体事件类型映射图标
    switch (eventType.toLowerCase()) {
      case '浇水':
        iconData = Icons.water_drop_outlined;
        break;
      case '施肥':
        iconData = Icons.eco_outlined;
        break;
      case '喂食':
        iconData = Icons.restaurant_outlined;
        break;
      case '用药':
      case '疫苗':
        iconData = Icons.medical_services_outlined;
        break;
      case '驱虫':
        iconData = Icons.bug_report_outlined;
        break;
      case '体重':
        iconData = Icons.scale_outlined;
        break;
      case '换盆':
        iconData = Icons.yard_outlined;
        break;
      case '洗澡':
      case '美容':
        iconData = Icons.bathtub_outlined;
        break;
      case '就诊':
        iconData = Icons.local_hospital_outlined;
        break;
      default:
        iconData = Icons.notes_outlined;
    }
    return Icon(iconData, color: Colors.grey[600]);
  }
}
