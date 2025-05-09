// lib/presentation/widgets/add_log_dialog.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' hide Column; // 隐藏 drift 的 Column

import '../../data/local/database/app_database.dart';
import '../../models/enum.dart';
import '../../providers/database_provider.dart';
import '../../providers/knowledge_provider.dart'; // !! 引入包含 allEventTypesStreamProvider 的文件 !!
import 'add_edit_event_type_dialog.dart'; // !! 引入添加/编辑类型的对话框 !!

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
  // 移除 _eventTypeController
  // final _eventTypeController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String? _selectedEventType; // 保持不变，存储选中的事件类型名称
  final List<XFile> _selectedImages = [];
  final List<String> _savedImagePaths = [];
  bool _isSaving = false;
  // 移除 _showCustomEventTypeField
  // bool _showCustomEventTypeField = false;

  // 移除 _commonEventTypes getter
  // List<String> get _commonEventTypes { ... }

  @override
  void dispose() {
    _notesController.dispose();
    // 移除 _eventTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // !! 监听事件类型 Provider !!
    final eventTypesAsync = ref.watch(allEventTypesStreamProvider);

    return AlertDialog(
      title: const Text('添加日志记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 事件类型选择 (从 Provider 加载)
              eventTypesAsync.when(
                data: (eventTypes) {
                  // 准备下拉菜单项
                  List<DropdownMenuItem<String>> items =
                      eventTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type.name, // 使用 name 作为值
                              child: Row(
                                children: [
                                  Icon(
                                    type.iconCodepoint != null &&
                                            type.iconFontFamily != null
                                        ? IconData(
                                          type.iconCodepoint!,
                                          fontFamily: type.iconFontFamily!,
                                        )
                                        : Icons.label_outline, // Fallback icon
                                    size: 18,
                                    color: Colors.grey[700], // 统一颜色或根据类型颜色
                                  ),
                                  const SizedBox(width: 8),
                                  Text(type.name),
                                ],
                              ),
                            ),
                          )
                          .toList();

                  // 添加 "添加新类型..." 选项
                  const String addNewValue = "___ADD_NEW_EVENT_TYPE___";
                  items.add(
                    const DropdownMenuItem<String>(
                      value: addNewValue,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "添加新类型...",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );

                  return DropdownButtonFormField<String>(
                    value: _selectedEventType,
                    hint: const Text('选择事件类型 *'),
                    items: items,
                    onChanged: (String? newValue) {
                      if (newValue == addNewValue) {
                        // 调用显示添加类型对话框的方法
                        _showAddEditEventTypeDialog(context, ref);
                        // 清除当前选择，因为新类型尚未添加
                        setState(() {
                          _selectedEventType = null;
                        });
                        // 注意：对话框关闭后，这个下拉菜单需要能反映出新添加的类型
                        // 因为我们 watch 了 allEventTypesStreamProvider，它会自动重建
                      } else {
                        setState(() {
                          _selectedEventType = newValue;
                        });
                      }
                    },
                    validator: (value) => value == null ? '请选择事件类型' : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                    ),
                  );
                },
                loading:
                    () => const Padding(
                      // 优化加载状态显示
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                error:
                    (err, stack) => Padding(
                      // 优化错误状态显示
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '无法加载事件类型: $err',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
              ),

              // 2. 移除自定义事件输入框
              // if (_showCustomEventTypeField) ...
              const SizedBox(height: 16),
              // 3. 事件时间选择 (保持不变)
              _buildDateTimePicker(context),
              const SizedBox(height: 16),
              // 4. 备注输入 (保持不变)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '记录一些细节...(可选)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              // 5. 图片选择 (保持不变)
              _buildImageSelectionArea(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
          onPressed: _isSaving ? null : _saveLog,
        ),
      ],
    );
  }

  // --- Helper Widgets for Form ---

  Widget _buildDateTimePicker(BuildContext context) {
    // ... (代码保持不变) ...
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (pickedDate != null && mounted) {
          // Check mounted
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
          );
          if (pickedTime != null && mounted) {
            // Check mounted again
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
    // ... (代码保持不变) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('添加照片 (可选, 最多5张)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._selectedImages
                .map(
                  (image) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        File(image.path),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      InkWell(
                        onTap:
                            () => setState(() => _selectedImages.remove(image)),
                        child: Container(
                          /* ... close icon ... */
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
            if (_selectedImages.length < 5)
              GestureDetector(
                onTap: _showLogImageSourceActionSheet,
                child: Container(
                  /* ... add photo button ... */
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

  // --- 图片来源选择和处理逻辑 ---

  void _showLogImageSourceActionSheet() {
    // ... (代码保持不变) ...
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        // Renamed context to bc
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  _addImagesFromSource(ImageSource.gallery);
                  Navigator.of(bc).pop(); // Use bc here
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () {
                  _addImagesFromSource(ImageSource.camera);
                  Navigator.of(bc).pop(); // Use bc here
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addImagesFromSource(ImageSource source) async {
    // ... (代码保持不变) ...
    final ImagePicker picker = ImagePicker();
    List<XFile> pickedFiles = [];
    final currentCount =
        _selectedImages.length; // Get current count before picking

    try {
      // Add try-catch for picker errors
      if (source == ImageSource.camera) {
        if (currentCount < 5) {
          final XFile? image = await picker.pickImage(
            source: source,
            imageQuality: 85,
            maxWidth: 1024,
          );
          if (image != null) pickedFiles.add(image);
        } else {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('最多只能添加5张照片')));
          return;
        }
      } else {
        final remainingSlots = 5 - currentCount;
        if (remainingSlots > 0) {
          pickedFiles = await picker.pickMultiImage(
            imageQuality: 80,
            maxWidth: 1024,
          );
          if (pickedFiles.length > remainingSlots) {
            pickedFiles = pickedFiles.sublist(0, remainingSlots);
          }
        } else {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('最多只能添加5张照片')));
          return;
        }
      }
    } catch (e) {
      print("Error picking images: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e'), backgroundColor: Colors.red),
        );
    }

    if (pickedFiles.isNotEmpty && mounted) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  // --- 保存逻辑 ---
  Future<void> _saveLog() async {
    print("==> START _saveLog");
    if (_isSaving) {
      print("    Aborted: Already saving.");
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;
    print("    Form validation result: $isValid");

    if (isValid) {
      print("    Selected Event Type before saving: $_selectedEventType");
      if (_selectedEventType == null) {
        print("    Aborted: _selectedEventType is null.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择事件类型'), backgroundColor: Colors.red),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _isSaving = true;
      });
      print("    Set _isSaving = true");

      final db = ref.read(databaseProvider);
      final String eventType = _selectedEventType!;

      print("--> BEFORE _saveImagesToAppDirectory");
      await _saveImagesToAppDirectory();
      print("<-- AFTER _saveImagesToAppDirectory");

      print("    Creating LogEntriesCompanion with eventType: $eventType");

      // !! 修改 Value.ofNullable 的使用 !!
      final notesText = _notesController.text.trim();
      final photosJson =
          _savedImagePaths.isNotEmpty ? jsonEncode(_savedImagePaths) : null;

      final logCompanion = LogEntriesCompanion(
        objectId: Value(widget.objectId),
        objectType: Value(widget.objectType),
        eventType: Value(eventType),
        eventDateTime: Value(_selectedDateTime),
        // 如果 notesText 不为空，则使用 Value(notesText)，否则使用 const Value(null)
        notes: notesText.isNotEmpty ? Value(notesText) : const Value(null),
        // 如果 photosJson 不为空，则使用 Value(photosJson)，否则使用 const Value(null)
        photoPaths: photosJson != null ? Value(photosJson) : const Value(null),
        creationDate: Value(DateTime.now().toUtc()),
      );

      try {
        print("--> BEFORE db.insertLogEntry");
        await db.insertLogEntry(logCompanion);
        print("<-- AFTER db.insertLogEntry");

        if (mounted) {
          print("    Attempting to pop dialog (Success)");
          Navigator.of(context).pop(true);
          print("    Dialog popped successfully.");
        } else {
          print("    Save successful, but widget unmounted before pop.");
        }
      } catch (e, s) {
        print("!!!!! ERROR saving log: $e");
        print("!!!!! StackTrace: $s");
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存日志失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
      // finally block might not be strictly needed if catch handles _isSaving reset
    } else {
      print("    Form validation failed.");
      if (mounted && _isSaving) {
        setState(() => _isSaving = false);
      }
    }
    print("<== END _saveLog");
  }

  Future<void> _saveImagesToAppDirectory() async {
    // ... (代码保持不变, 确保文件名唯一) ...
    _savedImagePaths.clear();
    if (_selectedImages.isEmpty) return;
    final Directory appDir = await getApplicationDocumentsDirectory();
    for (final imageXFile in _selectedImages) {
      final String extension = p.extension(imageXFile.path);
      final String fileName =
          'log_${widget.objectId}_${DateTime.now().millisecondsSinceEpoch}_${_savedImagePaths.length}$extension';
      final String savedPath = p.join(appDir.path, fileName);
      try {
        print('Attempting to save image to: $savedPath');
        // Use saveTo for XFile
        await imageXFile.saveTo(savedPath);
        _savedImagePaths.add(savedPath);
        print('Successfully saved image: $savedPath');
      } catch (e) {
        print("Error saving file $fileName using saveTo: $e");
        // Optionally inform user about the specific image failure
      }
    }
  }

  // !! 新增: 显示添加/编辑事件类型对话框的方法 !!
  Future<void> _showAddEditEventTypeDialog(
    BuildContext context,
    WidgetRef ref, {
    CustomEventType? eventTypeToEdit,
  }) async {
    // Show the separate dialog widget
    final bool? result = await showDialog<bool>(
      context: context,
      // barrierDismissible: false, // Prevent dismissing by tapping outside? Optional.
      builder: (_) => AddEditEventTypeDialog(existingType: eventTypeToEdit),
    );

    // The stream provider `allEventTypesStreamProvider` will automatically
    // update the dropdown list if the dialog successfully adds/edits a type
    // because the underlying database changed. No manual refresh needed here.
    if (result == false && mounted) {
      // 注意检查 mounted
      // 这里显示的 SnackBar 会使用 AddLogDialog 的 ScaffoldMessenger
      // 如果 AddLogDialog 本身就有问题，还需要进一步处理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("保存事件类型失败（可能名称已存在）"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (result == true) {
      print("Event type dialog returned success.");
    }
  }
} // End of _AddLogDialogState
