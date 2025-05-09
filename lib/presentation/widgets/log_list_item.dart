// lib/presentation/widgets/log_list_item.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // !! 引入 Riverpod !!
import 'package:intl/intl.dart';
import '../../data/local/database/app_database.dart'; // 引入 LogEntry 和 TypedIconData
import '../../providers/knowledge_provider.dart'; // !! Or event_type_providers.dart, 引入 Provider !!
import '../../providers/database_provider.dart'; // For delete action

// Optional: Import AddLogDialog if needed for editing
// import 'add_log_dialog.dart';

// !! 改为 ConsumerWidget !!
class LogListItem extends ConsumerWidget {
  final LogEntry logEntry;

  const LogListItem({super.key, required this.logEntry});

  // --- Helper Functions for Actions ---

  // TODO: Implement Edit Log functionality
  void _editLog(BuildContext context, WidgetRef ref, LogEntry log) {
    print("Editing log: ${log.id}");
    // Option 1: Show the AddLogDialog again, pre-filled with log data
    // This requires modifying AddLogDialog to accept an optional LogEntry for editing.
    // showDialog(
    //   context: context,
    //   builder: (_) => AddLogDialog(
    //      objectId: log.objectId,
    //      objectType: log.objectType,
    //      logToEdit: log, // <-- Pass the log data
    //   ),
    // );

    // Option 2: Navigate to a dedicated Edit Log Screen (if needed)
    // context.pushNamed('editLog', extra: log);

    // Placeholder:
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('编辑日志功能待实现')));
  }

  // Confirm and Delete Log
  Future<void> _confirmDeleteLog(
    BuildContext context,
    WidgetRef ref,
    LogEntry log,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除日志?'),
            content: Text('确定要删除这条关于 "${log.eventType}" 的日志记录吗？此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      try {
        // TODO: Delete associated photos from file system
        if (log.photoPaths != null && log.photoPaths!.isNotEmpty) {
          try {
            final List<dynamic> decoded = jsonDecode(log.photoPaths!);
            final List<String> paths = decoded.cast<String>();
            for (final path in paths) {
              final file = File(path);
              if (await file.exists()) {
                await file.delete();
                print("Deleted associated log photo: $path");
              }
            }
          } catch (e) {
            print("Error deleting log photos: $e");
            // Continue deleting DB entry even if photo deletion fails
          }
        }
        // Delete log entry from database
        await db.deleteLogEntry(log.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('日志记录已删除')));
        }
      } catch (e) {
        print("Error deleting log entry: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除日志失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // !! 添加 WidgetRef ref !!
    final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
    final theme = Theme.of(context);

    // 解析照片路径 (保持不变)
    List<String> photoPaths = [];
    if (logEntry.photoPaths != null && logEntry.photoPaths!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(logEntry.photoPaths!);
        photoPaths =
            decoded.whereType<String>().toList(); // More robust casting
      } catch (e) {
        print('Error decoding photoPaths for log ${logEntry.id}: $e');
      }
    }

    // !! 异步获取图标 !!
    final iconAsyncValue = ref.watch(eventTypeIconProvider(logEntry.eventType));

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ), // Adjusted margin
      clipBehavior:
          Clip.antiAlias, // Improves visual consistency with rounded corners
      child: InkWell(
        // Make the whole card tappable for potential editing/viewing
        onTap: () => _editLog(context, ref, logEntry), // Example: Tap to edit
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // Top row: Icon, Event Type, Timestamp, Menu
                crossAxisAlignment: CrossAxisAlignment.start, // Align items top
                children: [
                  // Icon (loaded async)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2.0,
                    ), // Align icon slightly better
                    child: iconAsyncValue.when(
                      data:
                          (typedIcon) => Icon(
                            typedIcon.iconData,
                            size: 20,
                            color:
                                typedIcon.color ??
                                Colors.grey[700], // Consistent color
                          ),
                      // Make loading indicator smaller
                      loading:
                          () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                      error:
                          (_, __) => const Icon(
                            Icons.label_outline,
                            size: 20,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Event Type Text (Allow wrapping)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 2.0,
                      ), // Align text better
                      child: Text(
                        logEntry.eventType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0), // Align timestamp
                    child: Text(
                      dateTimeFormatter.format(logEntry.eventDateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // !! 添加编辑和删除菜单 !!
                  SizedBox(
                    // Constrain the size of the button touch area
                    width: 36,
                    height: 36,
                    child: PopupMenuButton<String>(
                      tooltip: "日志选项",
                      onSelected: (String result) {
                        if (result == 'edit') {
                          _editLog(context, ref, logEntry);
                        } else if (result == 'delete') {
                          _confirmDeleteLog(context, ref, logEntry);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined, size: 20),
                                title: Text(
                                  '编辑',
                                  style: TextStyle(fontSize: 14),
                                ),
                                dense: true, // Compact style
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  '删除',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                      // Use a smaller icon for less visual clutter
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.zero, // Remove default padding
                    ),
                  ),
                ],
              ),

              // Conditionally display Notes and Photos only if they exist
              if (logEntry.notes != null && logEntry.notes!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 30.0,
                    right: 10.0,
                  ), // Indent content
                  child: Text(
                    logEntry.notes!.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

              if (photoPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 30.0,
                  ), // Indent content
                  child: SizedBox(
                    height: 65, // Slightly increase height for padding
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ), // Add padding around images
                      scrollDirection: Axis.horizontal,
                      itemCount: photoPaths.length,
                      itemBuilder: (context, index) {
                        final path = photoPaths[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 6.0,
                          ), // Reduce spacing
                          child: InkWell(
                            // Allow tapping image for full view later
                            onTap: () {
                              // TODO: Implement full screen image view
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('查看大图功能待实现'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: ClipRRect(
                              // Add rounded corners to images
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.file(
                                File(path),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    /* ... error placeholder ... */
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // !! 移除 _getEventTypeIcon 方法 !!
  // Widget _getEventTypeIcon(String eventType) { ... }
}
