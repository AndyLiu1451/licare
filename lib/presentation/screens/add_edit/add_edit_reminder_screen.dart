import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_pet_log/presentation/screens/reminders/reminders_list_screen.dart';
import 'package:rrule/rrule.dart'; // Use rrule package
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
// Hide Column from drift
import 'package:drift/drift.dart' hide Column;
// Import collection package
import 'package:collection/collection.dart';

import '../../../data/local/database/app_database.dart';
import '../../../models/enum.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/object_providers.dart';
import '../../../services/notification_service.dart';
import '../../../providers/list_filter_providers.dart';
// Ensure the screen name is correct for navigation
import '../reminders/reminders_list_screen.dart';

// Enum for UI selection
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

  late TextEditingController _taskNameController;
  late TextEditingController _notesController;
  late TextEditingController _customIntervalController;

  SelectableObject? _selectedObject;
  late tz.TZDateTime _nextDueDate;
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;
  List<bool> _weeklyDaysSelected = List.filled(7, false);
  int _monthlyDay = 1;
  String _customIntervalUnit = 'days';
  bool _isActive = true;
  DateTime? _originalCreationDate;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _initialDataLoaded = false;

  List<SelectableObject> _cachedSelectableObjects = [];

  @override
  void initState() {
    super.initState();
    print("[AddEditReminderScreen] initState START"); // <--- Log initState
    _taskNameController = TextEditingController();
    _notesController = TextEditingController();
    _customIntervalController = TextEditingController(text: '1');

    try {
      tz_data.initializeTimeZones();
      final location = tz.local;
      final now = tz.TZDateTime.now(location);
      _nextDueDate = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        now.hour,
        0,
      ).add(const Duration(hours: 1));
    } catch (e) {
      print("[AddEditReminderScreen] Error initializing timezone: $e");
      final nowUtc = DateTime.now().toUtc();
      _nextDueDate = tz.TZDateTime.utc(
        nowUtc.year,
        nowUtc.month,
        nowUtc.day,
        nowUtc.hour,
      ).add(const Duration(hours: 1));
    }

    _isLoading = widget.isEditing;
    _fetchSelectableObjectsAndLoadData();
    print("[AddEditReminderScreen] initState END"); // <--- Log initState End
  }

  Future<void> _fetchSelectableObjectsAndLoadData() async {
    print(
      "[AddEditReminderScreen] _fetchSelectableObjectsAndLoadData START",
    ); // <--- Log Fetch Start
    // Ensure loading state is managed correctly
    if (!mounted) return; // Check mounted at the beginning
    if (!_isLoading) {
      // Only set loading if not already loading
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final objects = await ref.read(selectableObjectsProvider.future);
      print(
        "[AddEditReminderScreen] _fetchSelectableObjectsAndLoadData - Objects fetched",
      ); // <--- Log Objects Fetched
      if (!mounted) return;
      setState(() {
        _cachedSelectableObjects = objects;
        if (widget.isEditing) {
          print(
            "[AddEditReminderScreen] _fetchSelectableObjectsAndLoadData - Calling _loadReminderData",
          ); // <--- Log Before Load
          _loadReminderData(); // Let _loadReminderData handle setting isLoading=false
        } else {
          _isLoading = false;
          _initialDataLoaded = true;
          print(
            "[AddEditReminderScreen] _fetchSelectableObjectsAndLoadData - Ready for ADD mode",
          ); // <--- Log Add Ready
        }
      });
    } catch (error) {
      print(
        "[AddEditReminderScreen] Error fetching selectable objects: $error",
      ); // <--- Log Error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载关联对象列表失败: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
        _initialDataLoaded = true;
      });
    }
    print(
      "[AddEditReminderScreen] _fetchSelectableObjectsAndLoadData END",
    ); // <--- Log Fetch End
  }

  Future<void> _loadReminderData() async {
    print(
      "[AddEditReminderScreen] _loadReminderData START",
    ); // <--- Log Load Start
    if (!widget.isEditing || widget.reminderId == null || _initialDataLoaded) {
      print(
        "[AddEditReminderScreen] _loadReminderData - Skipped (isEditing=${widget.isEditing}, id=${widget.reminderId}, loaded=$_initialDataLoaded)",
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
    final location = tz.local;

    try {
      final db = ref.read(databaseProvider);
      print(
        "[AddEditReminderScreen] _loadReminderData - Getting reminder from DB",
      ); // <--- Log DB Get Start
      final reminder = await db.getReminder(widget.reminderId!);
      print(
        "[AddEditReminderScreen] _loadReminderData - Got reminder: ${reminder != null}",
      ); // <--- Log DB Get End
      if (reminder != null && mounted) {
        setState(() {
          print(
            "[AddEditReminderScreen] _loadReminderData - Setting state",
          ); // <--- Log SetState Start
          _taskNameController.text = reminder.taskName;
          _notesController.text = reminder.notes ?? '';
          _nextDueDate = tz.TZDateTime.from(reminder.nextDueDate, location);
          _isActive = reminder.isActive;
          _originalCreationDate = reminder.creationDate;
          _selectedObject = _cachedSelectableObjects.firstWhereOrNull(
            (obj) =>
                obj.id == reminder.objectId && obj.type == reminder.objectType,
          );
          if (_selectedObject == null) {
            print(
              "[AddEditReminderScreen] Warning: Associated object not found.",
            );
          }
          _parseFrequencyRule(reminder.frequencyRule);
          _initialDataLoaded = true;
          _isLoading = false; // Loading finished
          print(
            "[AddEditReminderScreen] _loadReminderData - Setting state END",
          ); // <--- Log SetState End
        });
      } else if (mounted) {
        print(
          "[AddEditReminderScreen] _loadReminderData - Reminder not found or unmounted",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('找不到提醒数据'), backgroundColor: Colors.red),
        );
        context.pop();
        setState(() {
          _isLoading = false;
          _initialDataLoaded = true;
        });
      }
    } catch (e) {
      print(
        "[AddEditReminderScreen] Error loading reminder data: $e",
      ); // <--- Log Load Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载提醒数据失败: $e'), backgroundColor: Colors.red),
        );
        context.pop();
        setState(() {
          _isLoading = false;
          _initialDataLoaded = true;
        });
      }
    }
    print("[AddEditReminderScreen] _loadReminderData END"); // <--- Log Load End
  }

  // Parse RRULE string from DB into UI state
  void _parseFrequencyRule(String? ruleString) {
    print(
      "[AddEditReminderScreen] _parseFrequencyRule START: $ruleString",
    ); // <--- Log Parse Start
    setState(() {
      // ... (parsing logic as before) ...
      if (ruleString == null || ruleString.isEmpty || ruleString == 'ONCE') {
        _selectedFrequency = ReminderFrequency.once;
        _clearNonApplicableFrequencyState(_selectedFrequency);
        return;
      }
      try {
        final rrule = RecurrenceRule.fromString(ruleString);
        final freq = rrule.frequency;
        final interval = rrule.interval;
        final byWeekDays = rrule.byWeekDays;
        final byMonthDays = rrule.byMonthDays;
        ReminderFrequency parsedFrequency = ReminderFrequency.once;
        if (freq == Frequency.daily) {
          if (interval == 1) {
            parsedFrequency = ReminderFrequency.daily;
          } else {
            parsedFrequency = ReminderFrequency.custom;
            _customIntervalController.text = interval.toString();
            _customIntervalUnit = 'days';
          }
        } else if (freq == Frequency.weekly) {
          if (interval == 1 && byWeekDays.isNotEmpty) {
            parsedFrequency = ReminderFrequency.weekly;
            _weeklyDaysSelected = List.filled(7, false);
            for (var entry in byWeekDays) {
              if (entry.day >= 0 && entry.day < 7) {
                _weeklyDaysSelected[entry.day] = true;
              }
            }
          } else {
            parsedFrequency = ReminderFrequency.custom;
            _customIntervalController.text = interval.toString();
            _customIntervalUnit = 'weeks';
          }
        } else if (freq == Frequency.monthly) {
          if (interval == 1 &&
              byMonthDays.isNotEmpty &&
              byMonthDays.length == 1) {
            parsedFrequency = ReminderFrequency.monthly;
            _monthlyDay = byMonthDays.first;
            if (_monthlyDay < 1 || _monthlyDay > 31) _monthlyDay = 1;
          } else {
            parsedFrequency = ReminderFrequency.custom;
            _customIntervalController.text = interval.toString();
            _customIntervalUnit = 'months';
          }
        }
        _selectedFrequency = parsedFrequency;
        _clearNonApplicableFrequencyState(_selectedFrequency);
      } catch (e) {
        print(
          "[AddEditReminderScreen] Error parsing RRULE string '$ruleString': $e",
        );
        _selectedFrequency = ReminderFrequency.once;
        _clearNonApplicableFrequencyState(_selectedFrequency);
      }
    });
    print(
      "[AddEditReminderScreen] _parseFrequencyRule END",
    ); // <--- Log Parse End
  }

  // Reset state for frequencies not currently selected
  void _clearNonApplicableFrequencyState(ReminderFrequency currentFrequency) {
    if (currentFrequency != ReminderFrequency.custom) {
      _customIntervalController.text = '1';
      _customIntervalUnit = 'days';
    }
    if (currentFrequency != ReminderFrequency.weekly) {
      _weeklyDaysSelected = List.filled(7, false);
    }
    if (currentFrequency != ReminderFrequency.monthly) {
      _monthlyDay = 1;
    }
  }

  @override
  void dispose() {
    print("[AddEditReminderScreen] dispose"); // <--- Log dispose
    _taskNameController.dispose();
    _notesController.dispose();
    _customIntervalController.dispose();
    super.dispose();
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    print(
      "[AddEditReminderScreen] build START (isLoading: $_isLoading, initialDataLoaded: $_initialDataLoaded, isSaving: $_isSaving)",
    ); // <--- Log build
    final title = widget.isEditing ? '编辑提醒' : '添加提醒';
    final bool canBuildForm = _initialDataLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_isLoading && canBuildForm)
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
              // !! Add Log in onPressed !!
              onPressed:
                  _isSaving
                      ? null
                      : () {
                        print(
                          "[AddEditReminderScreen] Save button tapped! _isSaving is $_isSaving",
                        ); // <--- Log Button Tap
                        if (!_isSaving) {
                          // Double check _isSaving before calling
                          _saveReminder();
                        } else {
                          print(
                            "[AddEditReminderScreen] Save button tapped but _isSaving was true!",
                          );
                        }
                      },
            ),
        ],
      ),
      body:
          _isLoading || !canBuildForm
              ? const Center(child: CircularProgressIndicator())
              : _buildFormContent(),
    );
    print("[AddEditReminderScreen] build END"); // <--- Log build End
  }

  // Builds the main form content
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          // Flutter's Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Associated Object Dropdown
            if (_cachedSelectableObjects.isNotEmpty)
              DropdownButtonFormField<SelectableObject>(
                value: _selectedObject,
                hint: const Text('关联对象 *'),
                items:
                    _cachedSelectableObjects
                        .map(
                          (SelectableObject obj) =>
                              DropdownMenuItem<SelectableObject>(
                                value: obj,
                                child: Text(obj.displayName),
                              ),
                        )
                        .toList(),
                onChanged:
                    (SelectableObject? newValue) =>
                        setState(() => _selectedObject = newValue),
                validator: (value) => value == null ? '请选择关联对象' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
            // Show message only if NOT loading AND objects are empty AND initial load attempt finished
            else if (!_isLoading && _initialDataLoaded)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "没有可关联的对象。请先添加植物或宠物。",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            // 2. Task Name
            TextFormField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: '任务名称 *',
                hintText: '例如：浇水、喂食',
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
            // Conditional Options based on _selectedFrequency
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
              onChanged: (bool value) => setState(() => _isActive = value),
              secondary: Icon(
                _isActive
                    ? Icons.notifications_active
                    : Icons.notifications_off,
              ),
            ),
            const SizedBox(height: 30),
            // 7. Delete Button
            if (widget.isEditing)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    '删除提醒',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: _isSaving ? null : _confirmDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Form Field Builder Widgets ---
  // (These methods remain unchanged)
  Widget _buildDateTimePicker(BuildContext context) {
    /* ... */
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final displayDate = _nextDueDate;
    return InkWell(
      onTap: () async {
        /* ... date/time picker logic ... */
        final location = tz.local;
        final initialDt = _nextDueDate;
        final firstDt = tz.TZDateTime.now(
          location,
        ).subtract(const Duration(days: 90));
        final lastDt = tz.TZDateTime.now(
          location,
        ).add(const Duration(days: 365 * 5));
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDt,
          firstDate: firstDt,
          lastDate: lastDt,
        );
        if (pickedDate != null && mounted) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDt),
          );
          if (pickedTime != null && mounted) {
            setState(() {
              _nextDueDate = tz.TZDateTime(
                location,
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
    /* ... */
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
            _clearNonApplicableFrequencyState(newValue);
          });
        }
      },
    );
  }

  Widget _buildWeeklyDaySelector() {
    /* ... */
    const List<String> days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '选择星期几 *',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 6.0,
            runSpacing: 0,
            children: List<Widget>.generate(7, (int index) {
              return FilterChip(
                label: Text(days[index]),
                selected: _weeklyDaysSelected[index],
                onSelected:
                    (bool selected) =>
                        setState(() => _weeklyDaysSelected[index] = selected),
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color:
                      _weeklyDaysSelected[index]
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyDaySelector() {
    /* ... */
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonFormField<int>(
        value: _monthlyDay,
        decoration: const InputDecoration(
          labelText: '选择日期 *',
          border: OutlineInputBorder(),
        ),
        items:
            List<int>.generate(31, (i) => i + 1)
                .map(
                  (int day) =>
                      DropdownMenuItem<int>(value: day, child: Text('$day 号')),
                )
                .toList(),
        onChanged: (int? newValue) {
          if (newValue != null) setState(() => _monthlyDay = newValue);
        },
        validator: (value) {
          if (_selectedFrequency == ReminderFrequency.monthly &&
              value == null) {
            return '请选择日期';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCustomIntervalSelector() {
    /* ... */
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text("每隔 "),
          ),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_selectedFrequency == ReminderFrequency.custom) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 1) {
                    return '输入>0数字';
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
                if (newValue != null)
                  setState(() => _customIntervalUnit = newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Methods ---

  // Generate RRULE string or null
  String? _generateFrequencyRule() {
    print(
      "[AddEditReminderScreen] ==> START _generateFrequencyRule - Selected Freq: $_selectedFrequency",
    );
    Frequency? frequency;
    int interval = 1;
    List<ByWeekDayEntry> byWeekDays = [];
    List<int> byMonthDays = [];

    switch (_selectedFrequency) {
      case ReminderFrequency.once:
        print("<== END _generateFrequencyRule - Result: null (Once)");
        return null; // Return null for 'once'
      case ReminderFrequency.daily:
        frequency = Frequency.daily;
        break;
      case ReminderFrequency.weekly:
        frequency = Frequency.weekly;
        final List<int> weekDayInts = [1, 2, 3, 4, 5, 6, 7]; // Mon=0, Sun=6
        for (int i = 0; i < 7; i++) {
          if (_weeklyDaysSelected[i]) {
            byWeekDays.add(ByWeekDayEntry(weekDayInts[i]));
          }
        }
        if (byWeekDays.isEmpty) {
          print(
            "Warning: Generating weekly RRULE with no days selected. This might cause issues.",
          );
        }
        break;
      case ReminderFrequency.monthly:
        frequency = Frequency.monthly;
        byMonthDays.add(_monthlyDay);
        break;
      case ReminderFrequency.custom:
        interval = int.tryParse(_customIntervalController.text) ?? 1;
        if (interval < 1) interval = 1;
        switch (_customIntervalUnit) {
          case 'days':
            frequency = Frequency.daily;
            break;
          case 'weeks':
            frequency = Frequency.weekly;
            break;
          case 'months':
            frequency = Frequency.monthly;
            break;
          default:
            print(
              "<== END _generateFrequencyRule - Result: null (Invalid Custom Unit)",
            );
            return null;
        }
        break;
    }

    if (frequency == null) {
      print(
        "<== END _generateFrequencyRule - Result: null (Frequency not determined)",
      );
      return null;
    }

    // !! 不再传递 dtstart !!
    final rrule = RecurrenceRule(
      frequency: frequency,
      interval: interval,
      byWeekDays: byWeekDays, // 这些参数是存在的
      byMonthDays: byMonthDays, // 这些参数是存在的
      // 其他可能需要的参数: until, count, bySetPos, etc.
    );

    final ruleString = rrule.toString();
    // 检查生成的字符串格式，它不会包含 DTSTART
    print("    Generated RRULE String (No DTSTART): $ruleString");
    print("<== END _generateFrequencyRule - Result: $ruleString");
    return ruleString;
  }

  // Save reminder data
  Future<void> _saveReminder() async {
    // Double check saving state at the very beginning
    if (_isSaving) {
      print("[AddEditReminderScreen] _saveReminder aborted: Already saving.");
      return;
    }

    // Ensure object is selected
    if (_selectedObject == null) {
      final String errorMsg =
          _cachedSelectableObjects.isNotEmpty ? '请选择关联对象' : '无法保存提醒，请先添加植物或宠物';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      return;
    }

    print("[AddEditReminderScreen] _saveReminder: Validating form...");
    bool isValid = _formKey.currentState?.validate() ?? false;
    print(
      "[AddEditReminderScreen] _saveReminder: Form validation result: $isValid",
    );

    if (isValid) {
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

      // Set saving state and trigger UI update for loading indicator
      if (!mounted) return; // Check mounted before setState
      setState(() {
        _isSaving = true;
      });
      print(
        "[AddEditReminderScreen] _saveReminder: Set _isSaving=true and rebuilding UI",
      );

      // Read providers needed for the operation
      late AppDatabase db;
      late NotificationService notificationService;
      try {
        print("[AddEditReminderScreen] _saveReminder: Reading providers...");
        db = ref.read(databaseProvider);
        notificationService = ref.read(notificationServiceProvider);
        print(
          "[AddEditReminderScreen] _saveReminder: Providers read successfully.",
        );
      } catch (e) {
        print(
          "[AddEditReminderScreen] _saveReminder: Error reading providers: $e",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('发生内部错误: $e'), backgroundColor: Colors.red),
          );
          setState(() {
            _isSaving = false;
          }); // Reset state on provider error
        }
        return; // Stop execution if providers fail
      }

      final String? frequencyRule = _generateFrequencyRule(); // Returns String?
      final now = DateTime.now();
      final notesText = _notesController.text.trim();
      final notesValue = notesText.isEmpty ? null : notesText; // String?

      final DateTime creationDateValue =
          widget.isEditing ? (_originalCreationDate ?? now) : now;
      // !! 关键: 转换本地 TZDateTime 为 UTC DateTime 进行存储 !!
      final DateTime nextDueDateUtc = _nextDueDate.toUtc();
      final DateTime creationDateUtc =
          (widget.isEditing ? _originalCreationDate ?? now : now).toUtc();
      print(
        "[AddEditReminderScreen] _saveReminder: Saving nextDueDate as UTC: ${nextDueDateUtc.toIso8601String()}",
      );

      // Use Value.ofNullable for nullable fields
      final reminderCompanion = RemindersCompanion(
        id: widget.isEditing ? Value(widget.reminderId!) : const Value.absent(),
        objectId: Value(_selectedObject!.id),
        objectType: Value(_selectedObject!.type),
        taskName: Value(_taskNameController.text.trim()),

        // 显式处理 nullable frequencyRule
        frequencyRule:
            frequencyRule == null
                ? Value(null) // 不带 const
                : Value(frequencyRule),

        // 显式处理 nullable notes
        notes:
            notesValue == null
                ? Value(null) // 不带 const
                : Value(notesValue),

        nextDueDate: Value(nextDueDateUtc), // 非空 UTC DateTime
        isActive: Value(_isActive), // 非空 bool
        creationDate: Value(creationDateValue.toUtc()), // 非空 UTC DateTime
      );

      bool saveSuccess = false; // Flag to track success for finally block

      try {
        int savedReminderId;
        print(
          "[AddEditReminderScreen] Saving reminder: DB Insert/Update START",
        );
        if (widget.isEditing) {
          await db.updateReminder(reminderCompanion);
          savedReminderId = widget.reminderId!;
        } else {
          savedReminderId = await db.insertReminder(reminderCompanion);
        }
        print(
          "[AddEditReminderScreen] Saving reminder: DB Insert/Update END (ID: $savedReminderId)",
        );

        print("[AddEditReminderScreen] Saving reminder: DB Get Reminder START");
        final savedReminder = await db.getReminder(savedReminderId);
        print(
          "[AddEditReminderScreen] Saving reminder: DB Get Reminder END (Result: ${savedReminder != null})",
        );

        if (savedReminder != null) {
          // --- 时区转换，准备传递给通知服务 ---
          try {
            tz_data.initializeTimeZones();
          } catch (_) {}
          final location = tz.local;
          // 从 DB 读取的 UTC DateTime
          final DateTime nextDueUtcFromDb = savedReminder.nextDueDate;
          print(
            "[AddEditReminderScreen] nextDueUtcFromDb read: ${nextDueUtcFromDb.toIso8601String()} (isUtc: ${nextDueUtcFromDb.isUtc})",
          );
          // 转换为本地 TZDateTime
          final tz.TZDateTime nextDueLocalTz = tz.TZDateTime.from(
            nextDueUtcFromDb,
            location,
          );
          print(
            "[AddEditReminderScreen] Converted nextDueLocalTz for notification: ${nextDueLocalTz.toIso8601String()} (Location: ${nextDueLocalTz.location.name})",
          );

          // 创建新的 Reminder 实例或修改现有实例以包含正确的 TZDateTime
          // (如果 Reminder 类直接使用 DateTime，则传递 TZDateTime 可能需要修改服务接口)
          // 这里假设 NotificationService 可以接受包含 TZDateTime 的 Reminder (或者我们修改它)
          // 或者，我们只传递 TZDateTime 给服务？为了代码清晰，我们创建一个包含 TZDateTime 的副本。
          final reminderForNotif = Reminder(
            id: savedReminder.id,
            objectId: savedReminder.objectId,
            objectType: savedReminder.objectType,
            taskName: savedReminder.taskName,
            frequencyRule: savedReminder.frequencyRule,
            // !! 使用转换后的本地 TZDateTime !!
            nextDueDate: nextDueLocalTz,
            notes: savedReminder.notes,
            isActive: savedReminder.isActive,
            creationDate:
                savedReminder.creationDate, // creationDate 保持 DateTime
          );
          // --- 时区转换结束 ---

          print(
            "[AddEditReminderScreen] Saving reminder: Notification Cancel/Schedule START",
          );
          if (widget.isEditing) {
            await notificationService.cancelNotification(savedReminder.id);
          }
          if (savedReminder.isActive) {
            // !! 传递包含正确本地 TZDateTime 的对象 !!
            await notificationService.scheduleReminderNotification(
              reminderForNotif,
            );
          } else {
            await notificationService.cancelNotification(savedReminder.id);
          }
          print(
            "[AddEditReminderScreen] Saving reminder: Notification Cancel/Schedule END",
          );

          saveSuccess = true; // Mark as successful

          if (mounted) {
            print(
              "[AddEditReminderScreen] Saving reminder: Success! Showing SnackBar and Popping.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('提醒已${widget.isEditing ? '更新' : '添加'}')),
            );
            // 使用 maybePop 避免在无法 pop 时出错
            if (context.canPop()) {
              context.pop(); // Pop only on success
            } else {
              print(
                "[AddEditReminderScreen] Warning: context.canPop() returned false after successful save.",
              );
            }
          } else {
            print(
              "[AddEditReminderScreen] Saving reminder: Success, but widget unmounted before pop.",
            );
          }
        } else {
          print(
            "[AddEditReminderScreen] Saving reminder: Failed to retrieve reminder after save.",
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('保存后未能检索提醒，请重试'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print(
          "[AddEditReminderScreen] Error during DB/Notification operation: $e",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存提醒失败: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        print(
          "[AddEditReminderScreen] Saving reminder: FINALLY block (Success: $saveSuccess, Mounted: $mounted)",
        );
        // Only call setState to reset _isSaving if the operation failed AND the widget is still mounted.
        if (mounted && !saveSuccess) {
          print(
            "[AddEditReminderScreen] Saving reminder: Resetting _isSaving state due to failure.",
          );
          setState(() {
            _isSaving = false;
          });
        } else {
          _isSaving = false; // Reset flag logically regardless
          print(
            "[AddEditReminderScreen] Saving reminder: _isSaving flag reset logically.",
          );
        }
      }
    } else {
      // Form validation failed
      print("[AddEditReminderScreen] _saveReminder: Form validation failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单内容'),
          backgroundColor: Colors.orange,
        ),
      );
      if (_isSaving) {
        setState(() {
          _isSaving = false;
        });
      } // Reset if somehow set
    }
    print("[AddEditReminderScreen] _saveReminder END");
  }

  // Confirm and delete reminder
  Future<void> _confirmDelete() async {
    print(
      "[AddEditReminderScreen] _confirmDelete START",
    ); // <--- Log Delete Start
    if (!widget.isEditing || widget.reminderId == null) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        /* ... AlertDialog ... */
        return AlertDialog(
          title: const Text('确认删除提醒?'),
          content: const Text('确定要删除此提醒吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    print(
      "[AddEditReminderScreen] _confirmDelete - Dialog result: $result",
    ); // <--- Log Dialog Result

    if (result == true) {
      // Use mounted check before setState
      if (!mounted) {
        print(
          "[AddEditReminderScreen] _confirmDelete: Unmounted before setting saving state.",
        );
        return;
      }
      setState(() {
        _isSaving = true;
      }); // Show loading during delete
      print("[AddEditReminderScreen] _confirmDelete: Set _isSaving=true");

      // Read providers
      late AppDatabase db;
      late NotificationService notificationService;
      try {
        print("[AddEditReminderScreen] _confirmDelete: Reading providers...");
        db = ref.read(databaseProvider);
        notificationService = ref.read(notificationServiceProvider);
        print(
          "[AddEditReminderScreen] _confirmDelete: Providers read successfully.",
        );
      } catch (e) {
        print(
          "[AddEditReminderScreen] _confirmDelete: Error reading providers: $e",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('发生内部错误: $e'), backgroundColor: Colors.red),
          );
          setState(() {
            _isSaving = false;
          }); // Reset state
        }
        return;
      }

      try {
        print(
          "[AddEditReminderScreen] _confirmDelete: Cancelling notification...",
        );
        await notificationService.cancelNotification(widget.reminderId!);
        print("[AddEditReminderScreen] _confirmDelete: Deleting from DB...");
        await db.deleteReminder(widget.reminderId!);
        print("[AddEditReminderScreen] _confirmDelete: Delete successful.");
        if (mounted) {
          print(
            "[AddEditReminderScreen] _confirmDelete: Success! Showing SnackBar and Navigating back.",
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('提醒已删除')));
          context.goNamed(
            RemindersListScreen.routeName,
          ); // Use GoRouter to navigate back
          // No need to reset _isSaving here as we are navigating away
        } else {
          print(
            "[AddEditReminderScreen] _confirmDelete: Success, but widget unmounted before navigation.",
          );
        }
      } catch (e) {
        print(
          "[AddEditReminderScreen] Error deleting reminder: $e",
        ); // Log specific error
        if (mounted) {
          print(
            "[AddEditReminderScreen] _confirmDelete: Resetting _isSaving state due to failure.",
          );
          setState(() {
            _isSaving = false;
          }); // Reset state on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除提醒失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
      // No finally needed here as navigation happens on success, state reset on error
    } else {
      print(
        "[AddEditReminderScreen] _confirmDelete: Deletion cancelled by user.",
      );
    }
    print("[AddEditReminderScreen] _confirmDelete END"); // <--- Log Delete End
  }
}
