import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' hide Column; // <--- 添加这行

import '../../data/local/database/app_database.dart';
import '../../models/enum.dart';
import '../../providers/database_provider.dart'; // 引入 databaseProvider

class AddLogDialog extends ConsumerStatefulWidget {
  final int objectId;
  final ObjectType objectType;

  const AddLogDialog({
    super.key,
    required this.objectId,
    required this.objectType,
  });

  @override
  ConsumerState<AddLogDialog> createState() => _AddLogDialogState();
}

class _AddLogDialogState extends ConsumerState<AddLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _eventTypeController = TextEditingController(); // 用于自定义事件类型

  DateTime _selectedDateTime = DateTime.now(); // 默认事件时间为当前
  String? _selectedEventType; // 下拉选择的事件类型
  final List<XFile> _selectedImages = []; // 存储选择的图片文件 (XFile)
  final List<String> _savedImagePaths = []; // 存储保存后的图片路径
  bool _isSaving = false;
  bool _showCustomEventTypeField = false; // 是否显示自定义事件输入框

  // 定义常见的事件类型供选择
  List<String> get _commonEventTypes {
    if (widget.objectType == ObjectType.plant) {
      return ['浇水', '施肥', '换盆', '修剪', '光照变化', '病虫害', '其他'];
    } else {
      return [
        '喂食',
        '用药',
        '疫苗',
        '体内驱虫',
        '体外驱虫',
        '洗澡/美容',
        '体重记录',
        '行为观察',
        '就诊',
        '其他',
      ];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _eventTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加日志记录'),
      content: SingleChildScrollView(
        // 使内容可滚动
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // 对话框高度自适应内容
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 事件类型选择
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                hint: const Text('选择事件类型 *'),
                items:
                    _commonEventTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEventType = newValue;
                    // 如果选择“其他”，显示自定义输入框
                    _showCustomEventTypeField = (newValue == '其他');
                    if (!_showCustomEventTypeField) {
                      _eventTypeController.clear(); // 清除非“其他”时的自定义内容
                    }
                  });
                },
                validator: (value) {
                  if (value == null ||
                      (value == '其他' &&
                          _eventTypeController.text.trim().isEmpty)) {
                    return '请选择或输入事件类型';
                  }
                  return null;
                },
                isExpanded: true, // 让下拉菜单展开
              ),
              // 2. 自定义事件类型输入框 (条件显示)
              if (_showCustomEventTypeField)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _eventTypeController,
                    decoration: const InputDecoration(
                      hintText: '输入自定义事件类型 *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ), // 调整内边距
                    ),
                    validator: (value) {
                      if (_showCustomEventTypeField &&
                          (value == null || value.trim().isEmpty)) {
                        return '请输入自定义事件类型';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              const SizedBox(height: 16),
              // 3. 事件时间选择
              _buildDateTimePicker(context),
              const SizedBox(height: 16),
              // 4. 备注输入
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '记录一些细节...(可选)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // 允许多行输入
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              // 5. 图片选择
              _buildImageSelectionArea(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed:
              _isSaving ? null : () => Navigator.of(context).pop(), // 保存时禁用
        ),
        TextButton(
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('保存'),
          onPressed: _isSaving ? null : _saveLog, // 保存时禁用
        ),
      ],
    );
  }

  // --- Helper Widgets for Form ---

  Widget _buildDateTimePicker(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 30)), // 允许选择未来一点时间
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
          );
          if (pickedTime != null) {
            setState(() {
              _selectedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '事件时间 *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(formatter.format(_selectedDateTime)),
      ),
    );
  }

  Widget _buildImageSelectionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('添加照片 (可选)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          // 使用 Wrap 自动换行显示缩略图和添加按钮
          spacing: 8.0, // 水平间距
          runSpacing: 8.0, // 垂直间距
          children: [
            // 显示已选图片缩略图
            ..._selectedImages
                .map(
                  (image) => Stack(
                    // 使用 Stack 添加删除按钮
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        File(image.path),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      InkWell(
                        // 小删除按钮
                        onTap: () {
                          setState(() {
                            _selectedImages.remove(image);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
            // 添加图片按钮 (限制数量，比如最多5张)
            if (_selectedImages.length < 5)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- Logic ---

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    // 一次选择多张图片
    final List<XFile> images = await picker.pickMultiImage(
      imageQuality: 80, // 适当压缩图片质量
      maxWidth: 1024, // 限制最大宽度
    );

    if (images.isNotEmpty) {
      setState(() {
        // 限制总数
        final remainingSlots = 5 - _selectedImages.length;
        _selectedImages.addAll(images.take(remainingSlots));
      });
    }
  }

  Future<void> _saveLog() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSaving = true;
      });

      final db = ref.read(databaseProvider);
      final String eventType =
          (_selectedEventType == '其他'
              ? _eventTypeController.text.trim()
              : _selectedEventType)!;

      // 1. 保存图片到应用目录 (异步)
      await _saveImagesToAppDirectory();

      // 2. 创建 LogEntriesCompanion
      final logCompanion = LogEntriesCompanion(
        objectId: Value(widget.objectId),
        objectType: Value(widget.objectType),
        eventType: Value(eventType),
        eventDateTime: Value(_selectedDateTime),
        notes: Value(_notesController.text.trim()),
        // 将图片路径列表 JSON 编码后存储
        photoPaths: Value(
          _savedImagePaths.isNotEmpty ? jsonEncode(_savedImagePaths) : null,
        ),
        creationDate: Value(DateTime.now()), // 记录创建时间
      );

      try {
        // 3. 插入数据库
        await db.insertLogEntry(logCompanion);

        // 4. 关闭对话框
        if (mounted) Navigator.of(context).pop(true); // 返回 true 表示成功

        // 5. 显示成功提示 (可以在详情页显示)
        // ScaffoldMessenger.of(context).showSnackBar(...)
      } catch (e) {
        print('Error saving log: $e');
        if (mounted) {
          setState(() {
            _isSaving = false;
          }); // 出错时允许重试
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存日志失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
      // finally block not strictly needed here as pop() handles state update if successful
    }
  }

  Future<void> _saveImagesToAppDirectory() async {
    _savedImagePaths.clear(); // 清空旧路径
    if (_selectedImages.isEmpty) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    for (final imageFile in _selectedImages) {
      final String fileName =
          '${widget.objectId}_${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}'; // 创建唯一文件名
      final String savedPath = p.join(appDir.path, fileName);
      try {
        final File file = File(imageFile.path);
        await file.copy(savedPath);
        _savedImagePaths.add(savedPath);
      } catch (e) {
        print("Error copying file $fileName: $e");
        // 可以考虑给用户提示某张图片保存失败
      }
    }
  }
}
