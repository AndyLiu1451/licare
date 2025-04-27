// lib/models/photo_info.dart

// 用于统一表示照片来源和信息
class PhotoInfo {
  final String filePath; // 照片文件路径
  final DateTime dateTaken; // 照片关联的日期 (对象创建日期或日志日期)
  final PhotoSourceType sourceType; // 照片来源类型
  final String? sourceId; // 来源ID (对象ID 或 日志ID)
  final String? logEventType; // 如果是日志照片，记录事件类型 (可选)

  PhotoInfo({
    required this.filePath,
    required this.dateTaken,
    required this.sourceType,
    this.sourceId,
    this.logEventType,
  });
}

enum PhotoSourceType {
  objectProfile, // 对象主图
  logEntry, // 日志条目
}
