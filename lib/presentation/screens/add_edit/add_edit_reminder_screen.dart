import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/models/enum.dart';
import 'package:plant_pet_log/providers/database_provider.dart';
// Import NotificationService and its provider
import 'package:plant_pet_log/services/notification_service.dart';
import 'package:drift/drift.dart' show Value; // Import Value for Companions

class AddEditReminderScreen extends ConsumerStatefulWidget {
  final int? reminderId; // 编辑模式传入ID

  const AddEditReminderScreen({super.key, this.reminderId});

  bool get isEditing => reminderId != null;

  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends ConsumerState<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  // TODO: 添加 TextEditingControllers (任务名称, 备注)
  late TextEditingController _taskNameController;
  late TextEditingController _notesController;

  // TODO: 添加状态变量 (关联对象, 下次时间, 重复规则, 激活状态)
  SelectableObject? _selectedObject; // Example for selectable object
  DateTime _nextDueDate = DateTime.now().add(
    const Duration(days: 1),
  ); // Default next due date
  String _frequencyRule = 'ONCE'; // Default frequency
  bool _isActive = true; // Default active state
  DateTime _creationDate = DateTime.now(); // Needed for update

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.isEditing) {
      _loadReminderData();
    } else {
      // Initialize default values if needed
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadReminderData() async {
    if (!widget.isEditing) return;
    setState(() {
      _isLoading = true;
    });
    final db = ref.read(databaseProvider);
    try {
      final reminder = await db.getReminder(widget.reminderId!);
      if (reminder != null && mounted) {
        setState(() {
          _taskNameController.text = reminder.taskName;
          _notesController.text = reminder.notes ?? '';
          _nextDueDate = reminder.nextDueDate;
          _frequencyRule = reminder.frequencyRule;
          _isActive = reminder.isActive;
          _creationDate =
              reminder.creationDate; // Store creation date for update

          // TODO: Load and set the selected object (_selectedObject)
          // This requires fetching the corresponding Plant/Pet based on reminder.objectId/Type
          // For now, we'll skip this part of loading
        });
      } else if (mounted) {
        _showErrorSnackBar('找不到提醒数据');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('加载数据失败: $e');
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _saveReminder() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Trigger onSaved if used

      // TODO: Get actual values from form fields
      // final selectedObjectId = _selectedObject?.id;
      // final selectedObjectType = _selectedObject?.type;
      // if (selectedObjectId == null || selectedObjectType == null) {
      //    _showErrorSnackBar('请选择关联对象');
      //    return;
      // }
      // --- Placeholder values ---
      final selectedObjectId = 1; // Replace with actual selection
      final selectedObjectType =
          ObjectType.plant; // Replace with actual selection
      final taskName = _taskNameController.text.trim();
      final notes = _notesController.text.trim();
      // --- End Placeholder ---

      setState(() {
        _isSaving = true;
      });
      final db = ref.read(databaseProvider);
      // Get the notification service instance
      final notificationService = ref.read(notificationServiceProvider);

      final reminderCompanion = RemindersCompanion(
        id: widget.isEditing ? Value(widget.reminderId!) : const Value.absent(),
        objectId: Value(selectedObjectId),
        objectType: Value(selectedObjectType),
        taskName: Value(taskName),
        frequencyRule: Value(_frequencyRule), // TODO: Get from form
        nextDueDate: Value(_nextDueDate), // TODO: Get from form
        notes: Value(notes.isEmpty ? null : notes),
        isActive: Value(_isActive), // TODO: Get from form (Switch)
        // Use stored creation date for updates, new date for inserts
        creationDate: Value(widget.isEditing ? _creationDate : DateTime.now()),
      );

      try {
        Reminder? savedOrUpdatedReminder;
        if (widget.isEditing) {
          final success = await db.updateReminder(reminderCompanion);
          if (success) {
            savedOrUpdatedReminder = await db.getReminder(widget.reminderId!);
          }
        } else {
          final newId = await db.insertReminder(reminderCompanion);
          savedOrUpdatedReminder = await db.getReminder(newId);
        }

        // --- Notification Logic ---
        if (savedOrUpdatedReminder != null) {
          // If editing, always cancel the old notification first
          if (widget.isEditing) {
            print(
              "Cancelling previous notification for reminder ${savedOrUpdatedReminder.id}",
            );
            await notificationService.cancelNotification(
              savedOrUpdatedReminder.id,
            );
          }
          // If the reminder is active, schedule a new notification
          if (savedOrUpdatedReminder.isActive) {
            print(
              "Scheduling notification for reminder ${savedOrUpdatedReminder.id}",
            );
            await notificationService.scheduleReminderNotification(
              savedOrUpdatedReminder,
            );
          } else {
            // If it's not active (either saved as inactive or edited to become inactive) ensure no notification is scheduled
            // (The cancel call above handles the edit case, this is mainly for clarity on insert)
            if (!widget.isEditing) {
              // Only log cancellation on insert if it was saved as inactive
              print(
                "Reminder ${savedOrUpdatedReminder.id} saved as inactive. No notification scheduled.",
              );
              // No need to explicitly cancel here if it was never scheduled.
            }
          }
        }
        // --- End Notification Logic ---

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提醒已${widget.isEditing ? "更新" : "添加"}')),
          );
          Navigator.of(context).pop(); // Go back after saving
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('保存失败: $e');
      } finally {
        if (mounted)
          setState(() {
            _isSaving = false;
          });
      }
    } else {
      _showErrorSnackBar('请检查表单内容');
    }
  }

  // --- Delete Logic (Example) ---
  Future<void> _confirmDelete() async {
    if (!widget.isEditing) return; // Can only delete in edit mode

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除提醒?'),
            content: const Text('确定要删除此提醒吗？此操作无法撤销。'),
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

    if (result == true) {
      await _deleteReminder();
    }
  }

  Future<void> _deleteReminder() async {
    if (!widget.isEditing || widget.reminderId == null) return;

    setState(() {
      _isSaving = true;
    }); // Use saving indicator for delete operation

    final db = ref.read(databaseProvider);
    // Get notification service
    final notificationService = ref.read(notificationServiceProvider);
    final int reminderIdToDelete =
        widget.reminderId!; // Store before potential pop

    try {
      // 1. Delete from database
      await db.deleteReminder(reminderIdToDelete);

      // --- Notification Logic ---
      // 2. Cancel the corresponding notification
      print("Cancelling notification for deleted reminder $reminderIdToDelete");
      await notificationService.cancelNotification(reminderIdToDelete);
      // --- End Notification Logic ---

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('提醒已删除')));
        // Navigate back two steps (one for dialog, one for edit screen) or use go_router pop until list
        int popCount = 0;
        Navigator.of(context).popUntil((route) {
          return popCount++ == 1; // Pop twice
        });
        // Or: context.goNamed(RemindersListScreen.routeName); if using named routes properly
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('删除失败: $e');
    } finally {
      // Only set isSaving to false if deletion failed and widget is still mounted
      if (mounted && _isSaving && Navigator.canPop(context)) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).removeCurrentSnackBar(); // Remove previous snackbar if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? '编辑提醒' : '添加提醒';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_isLoading)
            IconButton(
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save),
              tooltip: '保存',
              onPressed: _isSaving ? null : _saveReminder,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Placeholder Form Fields ---
                      const Text(
                        '表单内容待实现:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // TODO: Add Dropdown for SelectableObject using selectableObjectsProvider
                      TextFormField(
                        controller: _taskNameController,
                        decoration: const InputDecoration(
                          labelText: '任务名称 *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? '任务名称不能为空'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      // TODO: Add DateTimePicker for _nextDueDate
                      Text('下次执行时间: ${_nextDueDate.toString()} (待实现选择器)'),
                      const SizedBox(height: 16),
                      // TODO: Add Dropdown/Selector for _frequencyRule
                      Text('重复规则: $_frequencyRule (待实现选择器)'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: '备注',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // TODO: Add SwitchListTile for _isActive
                      SwitchListTile(
                        title: const Text('激活提醒'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),

                      // --- End Placeholder ---
                      const SizedBox(height: 30),
                      if (widget.isEditing)
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            label: const Text(
                              '删除提醒',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed:
                                _isSaving
                                    ? null
                                    : _confirmDelete, // Disable delete while saving
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// You'll need the SelectableObject class defined (e.g., in object_providers.dart or models)
class SelectableObject {
  final int id;
  final String name;
  final ObjectType type;
  SelectableObject({required this.id, required this.name, required this.type});
  String get displayName => '${type == ObjectType.plant ? "[植]" : "[宠]"} $name';
}
