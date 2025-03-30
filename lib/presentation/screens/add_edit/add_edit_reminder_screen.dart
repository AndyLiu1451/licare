import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:intl/intl.dart'; // For date formatting
import 'package:collection/collection.dart'; // Import collection package
import '../../../data/local/database/app_database.dart';
import '../../../models/enum.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/object_providers.dart'; // For selectableObjectsProvider & reminderDetailsProvider
import '../../../services/notification_service.dart'; // For notification service
import '../../../presentation/screens/reminders/reminders_list_screen.dart';

// Simple enum for frequency selection UI
enum ReminderFrequency { once, daily, weekly, monthly, custom }

class AddEditReminderScreen extends ConsumerStatefulWidget {
  final int? reminderId;
  const AddEditReminderScreen({super.key, this.reminderId});
  bool get isEditing => reminderId != null;
  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends ConsumerState<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _taskNameController;
  late TextEditingController _notesController;
  late TextEditingController
  _customIntervalController; // For custom frequency interval

  // State Variables
  SelectableObject? _selectedObject; // The associated plant/pet
  DateTime _nextDueDate = DateTime.now().add(
    const Duration(hours: 1),
  ); // Default next due time
  ReminderFrequency _selectedFrequency =
      ReminderFrequency.once; // Default frequency
  List<bool> _weeklyDaysSelected = List.filled(
    7,
    false,
  ); // For weekly selection (Mon-Sun)
  int _monthlyDay = 1; // For monthly selection (day of month)
  String _customIntervalUnit = 'days'; // Default custom unit
  bool _isActive = true; // Default reminder status
  DateTime _creationDate = DateTime.now(); // Loaded in edit mode

  bool _isLoading = false;
  bool _isSaving = false;
  bool _initialDataLoaded =
      false; // Flag to prevent overwriting user changes during rebuilds

  // Cache selectable objects to avoid re-fetching during build
  List<SelectableObject> _cachedSelectableObjects = [];

  @override
  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _notesController = TextEditingController();
    _customIntervalController = TextEditingController(text: '1');

    // Set initial loading state to true. It stays true until
    // all necessary async operations (fetching objects, loading data if editing) complete or fail.
    _isLoading = true;
    _initialDataLoaded = false; // Data is not loaded yet

    // Start the asynchronous process of fetching objects and potentially loading data.
    // We don't await this here because initState cannot be async.
    _fetchSelectableObjectsAndLoadData();
  }

  // Helper function to chain async operations needed for initialization
  Future<void> _fetchSelectableObjectsAndLoadData() async {
    // Ensure we don't proceed if the widget is disposed during async gaps.
    if (!mounted) return;

    try {
      // 1. Fetch Selectable Objects (required for both add and edit)
      // Use 'ref.read' as we typically fetch this once during init.
      final objects = await ref.read(selectableObjectsProvider.future);
      if (!mounted) return; // Check mount status again after await

      // Store the fetched objects
      _cachedSelectableObjects = objects;

      // 2. Decide next step based on mode (Add vs Edit)
      if (widget.isEditing) {
        // If editing, now proceed to load the specific reminder details.
        // _loadReminderData will handle setting isLoading = false upon completion or error.
        await _loadReminderData();
      } else {
        // If adding, we have fetched the objects, and that's all we need.
        // Mark data as loaded and stop the loading indicator.
        setState(() {
          _isLoading = false;
          _initialDataLoaded = true;
        });
      }
    } catch (error) {
      // Handle error during fetching selectable objects
      print("Error fetching selectable objects: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载关联对象列表失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
        // Stop loading, but mark as 'loaded' to allow the UI to build,
        // even if it's just to show an error state or an empty dropdown.
        setState(() {
          _isLoading = false;
          _initialDataLoaded = true;
          _cachedSelectableObjects = []; // Ensure list is empty on error
        });
      }
    }
  }

  // This function is now only called IF editing and AFTER selectable objects are fetched.
  Future<void> _loadReminderData() async {
    // Basic guards
    if (!widget.isEditing || widget.reminderId == null) {
      // This case shouldn't ideally happen with the new initState logic,
      // but as a safeguard, ensure loading stops.
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    // _isLoading is already true, set by initState. No need to set it again here.

    try {
      final db = ref.read(databaseProvider);
      final reminder = await db.getReminder(widget.reminderId!);

      // Check mount status AGAIN after await before calling setState
      if (!mounted) return;

      if (reminder != null) {
        // Successfully loaded reminder, update UI state
        setState(() {
          _taskNameController.text = reminder.taskName;
          _notesController.text = reminder.notes ?? '';
          _nextDueDate = reminder.nextDueDate;
          _isActive = reminder.isActive;
          _creationDate = reminder.creationDate;

          _selectedObject = _cachedSelectableObjects.firstWhereOrNull(
            (obj) =>
                obj.id == reminder.objectId && obj.type == reminder.objectType,
          );
          // (Optional: handle _selectedObject == null case as before)

          _parseFrequencyRule(reminder.frequencyRule);

          // Mark initial data as loaded AND set loading to false
          _initialDataLoaded = true;
          _isLoading = false;
        });
      } else {
        // Reminder not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('找不到提醒数据'), backgroundColor: Colors.red),
        );
        context.pop(); // Go back
        // Also ensure loading stops if we pop
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle error during loading reminder details
      print("Error loading reminder data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载提醒数据失败: $e'), backgroundColor: Colors.red),
        );
        // Decide whether to pop or show error on the screen
        // context.pop();
        // Stop loading and mark as 'loaded' to allow build, maybe showing an error message in the form area
        setState(() {
          _isLoading = false;
          _initialDataLoaded =
              true; // Let the UI build, even if data is incomplete/error state
        });
      }
    }
  }

  // Parse the stored frequency string back into UI state
  void _parseFrequencyRule(String rule) {
    if (rule == 'ONCE') {
      _selectedFrequency = ReminderFrequency.once;
    } else if (rule == 'DAILY') {
      _selectedFrequency = ReminderFrequency.daily;
    } else if (rule.startsWith('WEEKLY:')) {
      _selectedFrequency = ReminderFrequency.weekly;
      final daysStr = rule.split(':')[1];
      final days = daysStr.split(','); // MON,TUE,...
      _weeklyDaysSelected = List.filled(7, false); // Reset
      const dayMap = {
        'MON': 0,
        'TUE': 1,
        'WED': 2,
        'THU': 3,
        'FRI': 4,
        'SAT': 5,
        'SUN': 6,
      };
      for (var day in days) {
        if (dayMap.containsKey(day.toUpperCase())) {
          _weeklyDaysSelected[dayMap[day.toUpperCase()]!] = true;
        }
      }
    } else if (rule.startsWith('MONTHLY:')) {
      _selectedFrequency = ReminderFrequency.monthly;
      _monthlyDay = int.tryParse(rule.split(':')[1]) ?? 1;
    } else if (rule.startsWith('EVERY:')) {
      _selectedFrequency = ReminderFrequency.custom;
      final parts = rule.split(':');
      if (parts.length == 3) {
        _customIntervalController.text = parts[1];
        _customIntervalUnit = parts[2];
      }
    } else {
      _selectedFrequency = ReminderFrequency.once; // Default fallback
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    _customIntervalController.dispose();
    super.dispose();
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? '编辑提醒' : '添加提醒';
    // Ensure data is loaded before building the form content
    final bool canBuildForm = _initialDataLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (canBuildForm) // Only show save when form is ready
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
          _isLoading ||
                  !canBuildForm // Show loading indicator if loading OR initial data not ready
              ? const Center(child: CircularProgressIndicator())
              : _buildFormContent(), // Build form content
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Associated Object Dropdown
            if (_cachedSelectableObjects
                .isNotEmpty) // Only show if objects exist
              DropdownButtonFormField<SelectableObject>(
                value: _selectedObject,
                hint: const Text('关联对象 *'),
                items:
                    _cachedSelectableObjects.map((SelectableObject obj) {
                      return DropdownMenuItem<SelectableObject>(
                        value: obj,
                        child: Text(obj.displayName),
                      );
                    }).toList(),
                onChanged: (SelectableObject? newValue) {
                  setState(() {
                    _selectedObject = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择关联对象' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
            else
              const Text(
                "没有可关联的对象。请先添加植物或宠物。",
                style: TextStyle(color: Colors.red),
              ), // Show message if no objects

            const SizedBox(height: 16),
            // 2. Task Name
            TextFormField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: '任务名称 *',
                hintText: '例如：浇水、喂食、打疫苗',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? '任务名称不能为空'
                          : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // 3. Next Due Date/Time
            _buildDateTimePicker(context),
            const SizedBox(height: 16),
            // 4. Frequency Selection
            _buildFrequencySelector(),
            // Conditional Frequency Options
            if (_selectedFrequency == ReminderFrequency.weekly)
              _buildWeeklyDaySelector(),
            if (_selectedFrequency == ReminderFrequency.monthly)
              _buildMonthlyDaySelector(),
            if (_selectedFrequency == ReminderFrequency.custom)
              _buildCustomIntervalSelector(),

            const SizedBox(height: 16),
            // 5. Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '(可选)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // 6. Active Status Switch
            SwitchListTile(
              title: const Text('激活提醒'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive
                    ? Icons.notifications_active
                    : Icons.notifications_off,
              ),
            ),
            const SizedBox(height: 30),
            // 7. Delete Button (Edit mode only)
            if (widget.isEditing)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    '删除提醒',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed:
                      _isSaving ? null : _confirmDelete, // Disable when saving
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Form Field Builder Widgets ---

  Widget _buildDateTimePicker(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _nextDueDate,
          firstDate: DateTime.now().subtract(
            const Duration(days: 30),
          ), // Allow slightly past date
          lastDate: DateTime.now().add(
            const Duration(days: 365 * 5),
          ), // Allow future dates
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_nextDueDate),
          );
          if (pickedTime != null) {
            setState(() {
              _nextDueDate = DateTime(
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
          labelText: '下次执行时间 *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(formatter.format(_nextDueDate)),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return DropdownButtonFormField<ReminderFrequency>(
      value: _selectedFrequency,
      decoration: const InputDecoration(
        labelText: '重复频率',
        border: OutlineInputBorder(),
      ),
      items:
          ReminderFrequency.values.map((ReminderFrequency freq) {
            String text;
            switch (freq) {
              case ReminderFrequency.once:
                text = '仅一次';
                break;
              case ReminderFrequency.daily:
                text = '每天';
                break;
              case ReminderFrequency.weekly:
                text = '每周';
                break;
              case ReminderFrequency.monthly:
                text = '每月';
                break;
              case ReminderFrequency.custom:
                text = '自定义间隔';
                break;
            }
            return DropdownMenuItem<ReminderFrequency>(
              value: freq,
              child: Text(text),
            );
          }).toList(),
      onChanged: (ReminderFrequency? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFrequency = newValue;
          });
        }
      },
    );
  }

  Widget _buildWeeklyDaySelector() {
    const List<String> days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InputDecorator(
        // Wrap in InputDecorator for consistent styling
        decoration: InputDecoration(
          labelText: '选择星期几',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ), // Adjust padding
        ),
        child: Padding(
          // Add internal padding
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 6.0,
            runSpacing: 0,
            children: List<Widget>.generate(7, (int index) {
              return FilterChip(
                label: Text(days[index]),
                selected: _weeklyDaysSelected[index],
                onSelected: (bool selected) {
                  setState(() {
                    _weeklyDaysSelected[index] = selected;
                  });
                },
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color:
                      _weeklyDaysSelected[index]
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                ),
                visualDensity: VisualDensity.compact, // Make chips smaller
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 0,
                ), // Adjust chip padding
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyDaySelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonFormField<int>(
        value: _monthlyDay,
        decoration: const InputDecoration(
          labelText: '选择日期',
          border: OutlineInputBorder(),
        ),
        items:
            List<int>.generate(31, (i) => i + 1).map((int day) {
              return DropdownMenuItem<int>(value: day, child: Text('$day 号'));
            }).toList(),
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              _monthlyDay = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildCustomIntervalSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Text("每隔 "),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _customIntervalController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_selectedFrequency == ReminderFrequency.custom) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 1) {
                    return '请输入有效数字';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: _customIntervalUnit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              items:
                  ['days', 'weeks', 'months'].map((String unit) {
                    String text;
                    switch (unit) {
                      case 'days':
                        text = '天';
                        break;
                      case 'weeks':
                        text = '周';
                        break;
                      case 'months':
                        text = '月';
                        break;
                      default:
                        text = unit;
                    }
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(text),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _customIntervalUnit = newValue;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Methods ---

  // Generate the frequency rule string for storage
  String _generateFrequencyRule() {
    switch (_selectedFrequency) {
      case ReminderFrequency.once:
        return 'ONCE';
      case ReminderFrequency.daily:
        return 'DAILY';
      case ReminderFrequency.weekly:
        const List<String> dayMap = [
          'MON',
          'TUE',
          'WED',
          'THU',
          'FRI',
          'SAT',
          'SUN',
        ];
        List<String> selectedDays = [];
        for (int i = 0; i < 7; i++) {
          if (_weeklyDaysSelected[i]) {
            selectedDays.add(dayMap[i]);
          }
        }
        // Ensure at least one day is selected for weekly
        if (selectedDays.isEmpty) {
          // Default to the day of _nextDueDate or Monday if validation fails
          selectedDays.add(dayMap[_nextDueDate.weekday - 1]);
          print(
            "Warning: No weekday selected for weekly reminder. Defaulting to ${selectedDays[0]}.",
          );
        }
        return 'WEEKLY:${selectedDays.join(',')}';
      case ReminderFrequency.monthly:
        return 'MONTHLY:$_monthlyDay';
      case ReminderFrequency.custom:
        final interval = int.tryParse(_customIntervalController.text) ?? 1;
        return 'EVERY:$interval:$_customIntervalUnit';
    }
  }

  Future<void> _saveReminder() async {
    if (_isSaving || _selectedObject == null)
      return; // Don't save if saving or no object selected

    if (_formKey.currentState!.validate()) {
      // Additional validation for weekly frequency
      if (_selectedFrequency == ReminderFrequency.weekly &&
          !_weeklyDaysSelected.contains(true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请至少选择一个星期几用于每周重复'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop saving
      }

      setState(() {
        _isSaving = true;
      });
      final db = ref.read(databaseProvider);
      final notificationService = ref.read(notificationServiceProvider);
      final frequencyRule = _generateFrequencyRule();
      final now = DateTime.now();

      final reminderCompanion = RemindersCompanion(
        id: widget.isEditing ? Value(widget.reminderId!) : const Value.absent(),
        objectId: Value(_selectedObject!.id),
        objectType: Value(_selectedObject!.type),
        taskName: Value(_taskNameController.text.trim()),
        frequencyRule: Value(frequencyRule),
        nextDueDate: Value(_nextDueDate),
        notes: Value(_notesController.text.trim()),
        isActive: Value(_isActive),
        creationDate: Value(widget.isEditing ? _creationDate : now),
      );

      try {
        int savedReminderId;
        if (widget.isEditing) {
          await db.updateReminder(reminderCompanion);
          savedReminderId = widget.reminderId!;
        } else {
          savedReminderId = await db.insertReminder(reminderCompanion);
        }

        // Fetch the saved/updated reminder to pass to notification service
        final savedReminder = await db.getReminder(savedReminderId);

        if (savedReminder != null) {
          // Cancel old notification (if editing) and schedule new one
          if (widget.isEditing) {
            await notificationService.cancelNotification(savedReminder.id);
          }
          if (savedReminder.isActive) {
            // Only schedule if active
            await notificationService.scheduleReminderNotification(
              savedReminder,
            );
          } else {
            // Ensure notification is cancelled if set to inactive
            await notificationService.cancelNotification(savedReminder.id);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('提醒已${widget.isEditing ? '更新' : '添加'}')),
            );
            context.pop(); // Go back after successful save
          }
        } else {
          throw Exception('Failed to retrieve saved reminder'); // Handle error
        }
      } catch (e) {
        print("Error saving reminder: $e");
        if (mounted) {
          setState(() {
            _isSaving = false;
          }); // Allow retry on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存提醒失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
      // finally block might be needed if setState isn't guaranteed after async gap + pop
      // finally {
      //   if (mounted && _isSaving) {
      //      setState(() { _isSaving = false; });
      //   }
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单内容'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (!widget.isEditing || widget.reminderId == null) return;

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
      setState(() {
        _isSaving = true;
      }); // Show loading indicator during delete
      final db = ref.read(databaseProvider);
      final notificationService = ref.read(notificationServiceProvider);

      try {
        await db.deleteReminder(widget.reminderId!);
        await notificationService.cancelNotification(
          widget.reminderId!,
        ); // Cancel associated notification

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('提醒已删除')));
          // Pop twice if dialog was involved? Or just pop once if dialog handles its own pop.
          // context.pop(); // Pop the edit screen
          // Go back to reminder list screen
          context.goNamed(RemindersListScreen.routeName);
        }
      } catch (e) {
        print("Error deleting reminder: $e");
        if (mounted) {
          setState(() {
            _isSaving = false;
          }); // Allow retry on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除提醒失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
