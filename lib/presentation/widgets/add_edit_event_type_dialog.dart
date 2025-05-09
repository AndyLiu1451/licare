import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pet_log/data/local/database/app_database.dart';
import 'package:plant_pet_log/providers/database_provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
// Optional: Import an icon picker package if you want a visual picker
// import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class AddEditEventTypeDialog extends ConsumerStatefulWidget {
  final CustomEventType? existingType; // Pass existing type for editing

  const AddEditEventTypeDialog({super.key, this.existingType});

  bool get isEditing => existingType != null;

  @override
  ConsumerState<AddEditEventTypeDialog> createState() =>
      _AddEditEventTypeDialogState();
}

class _AddEditEventTypeDialogState
    extends ConsumerState<AddEditEventTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  IconData? _selectedIcon;
  // Store codepoint and font family for saving
  int? _selectedIconCodepoint;
  String? _selectedIconFontFamily;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingType?.name ?? '',
    );
    if (widget.isEditing && widget.existingType?.iconCodepoint != null) {
      _selectedIconCodepoint = widget.existingType!.iconCodepoint;
      _selectedIconFontFamily = widget.existingType!.iconFontFamily;
      if (_selectedIconFontFamily != null) {
        _selectedIcon = IconData(
          _selectedIconCodepoint!,
          fontFamily: _selectedIconFontFamily!,
        );
      }
    } else {
      // Set a default icon maybe?
      _selectedIcon = Icons.label_outline; // Default icon suggestion
      _selectedIconCodepoint = _selectedIcon?.codePoint;
      _selectedIconFontFamily = _selectedIcon?.fontFamily;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Basic Icon Picker (Replace with flutter_iconpicker later if desired)
  Future<void> _pickIcon(BuildContext context) async {
    // Simple example: Show a dialog with a few preset icons
    final IconData? pickedIcon = await showDialog<IconData>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('选择图标'),
            content: SingleChildScrollView(
              // Allow scrolling if many icons
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Add more relevant icons here
                  IconButton(
                    icon: const Icon(Icons.water_drop),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.water_drop),
                  ),
                  IconButton(
                    icon: const Icon(Icons.eco),
                    onPressed: () => Navigator.of(context).pop(Icons.eco),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restaurant),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.restaurant),
                  ),
                  IconButton(
                    icon: const Icon(Icons.medical_services),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.medical_services),
                  ),
                  IconButton(
                    icon: const Icon(Icons.vaccines),
                    onPressed: () => Navigator.of(context).pop(Icons.vaccines),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bug_report),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.bug_report),
                  ),
                  IconButton(
                    icon: const Icon(Icons.scale),
                    onPressed: () => Navigator.of(context).pop(Icons.scale),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.visibility),
                  ),
                  IconButton(
                    icon: const Icon(Icons.local_hospital),
                    onPressed:
                        () => Navigator.of(context).pop(Icons.local_hospital),
                  ),
                  IconButton(
                    icon: const Icon(Icons.yard),
                    onPressed: () => Navigator.of(context).pop(Icons.yard),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cut),
                    onPressed: () => Navigator.of(context).pop(Icons.cut),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lightbulb),
                    onPressed: () => Navigator.of(context).pop(Icons.lightbulb),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pets),
                    onPressed: () => Navigator.of(context).pop(Icons.pets),
                  ),
                  IconButton(
                    icon: const Icon(Icons.label),
                    onPressed: () => Navigator.of(context).pop(Icons.label),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notes),
                    onPressed: () => Navigator.of(context).pop(Icons.notes),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ],
          ),
    );

    if (pickedIcon != null) {
      setState(() {
        _selectedIcon = pickedIcon;
        _selectedIconCodepoint = pickedIcon.codePoint;
        _selectedIconFontFamily = pickedIcon.fontFamily;
      });
    }

    // --- Using flutter_iconpicker (Example, requires adding dependency) ---
    // IconData? icon = await FlutterIconPicker.showIconPicker(
    //   context,
    //   iconPackModes: [IconPack.material], // Choose icon packs
    // );
    // if (icon != null) {
    //   setState(() {
    //     _selectedIcon = icon;
    //     _selectedIconCodepoint = icon.codePoint;
    //     _selectedIconFontFamily = icon.fontFamily;
    //   });
    // }
    // --- End flutter_iconpicker example ---
  }

  Future<void> _saveEventType() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final db = ref.read(databaseProvider);
      final name = _nameController.text.trim();

      // Prevent editing name of preset types (if isEditing and isPreset)
      if (widget.isEditing && widget.existingType!.isPreset) {
        // Only allow updating icon/color for presets
        final companion = widget.existingType!
            .toCompanion(true)
            .copyWith(
              iconCodepoint: Value(_selectedIconCodepoint),
              iconFontFamily: Value(_selectedIconFontFamily),
            );
        try {
          await db.updateEventType(companion);
          if (mounted) Navigator.of(context).pop(true); // Indicate success
        } catch (e) {
          print("Error updating preset event type icon: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("更新图标失败: $e"),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isSaving = false);
          }
        }
        return;
      }

      // For new types or editing custom types
      final companion = CustomEventTypesCompanion(
        id:
            widget.isEditing
                ? Value(widget.existingType!.id)
                : const Value.absent(),
        name: Value(name),
        iconCodepoint: Value(_selectedIconCodepoint),
        iconFontFamily: Value(_selectedIconFontFamily),
        isPreset: const Value(false), // User added/edited are never preset
      );

      try {
        if (widget.isEditing) {
          await db.updateEventType(companion);
        } else {
          await db.insertEventType(companion);
        }
        if (mounted) Navigator.of(context).pop(true); // Indicate success
      } catch (e) {
        print("Error saving event type: $e");
        if (mounted) {
          // Handle potential unique constraint error for name
          String errorMessage = "保存失败: $e";
          bool isUniqueConstraintError = false; // 标记是否是唯一约束错误
          if (e.toString().toLowerCase().contains('unique constraint failed')) {
            errorMessage = "错误：事件类型名称 '$name' 已存在。";
          }
          // !! 使用全局 Key 显示 SnackBar !!
          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG, // 显示时间长一点
            gravity: ToastGravity.CENTER, // 显示在中间或顶部 (TOP, CENTER, BOTTOM)
            timeInSecForIosWeb: 3, // iOS/Web 显示时间
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          setState(() => _isSaving = false); // 重置状态允许重试
        }
      }
    } else {
      // Form validation failed
      if (mounted && _isSaving) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? '编辑事件类型' : '添加新事件类型'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              // Disable name editing for preset types
              readOnly: widget.isEditing && widget.existingType!.isPreset,
              decoration: InputDecoration(
                labelText: '类型名称 *',
                icon:
                    _selectedIcon != null
                        ? Icon(_selectedIcon)
                        : null, // Show selected icon next to field
              ),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty) ? '名称不能为空' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.touch_app_outlined),
              title: const Text('选择图标'),
              trailing:
                  _selectedIcon != null
                      ? Icon(_selectedIcon, size: 28)
                      : const Text('未选择'),
              onTap: () => _pickIcon(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _isSaving ? null : _saveEventType,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('保存'),
        ),
      ],
    );
  }
}
