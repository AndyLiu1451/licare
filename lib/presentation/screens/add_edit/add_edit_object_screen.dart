import 'dart:convert'; // 用于序列化照片路径列表
import 'dart:io'; // 用于处理文件
import 'package:drift/drift.dart'
    hide Column; // <--- Add 'hide Column' // <--- 添加这行
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // 引入 image_picker
import 'package:intl/intl.dart'; // 引入 intl 用于日期格式化
import 'package:path_provider/path_provider.dart'; // 引入 path_provider
import 'package:path/path.dart' as p; // 引入 path

import '../../../data/local/database/app_database.dart'; // 引入数据库和 Companion 类
import '../../../models/enum.dart';
import '../../../providers/database_provider.dart'; // 引入 databaseProvider
// 需要在路由配置中引入 PlantListScreen 和 PetListScreen (如果之前没引入的话)
import '../../../presentation/screens/plants/plant_list_screen.dart';
import '../../../presentation/screens/pets/pet_list_screen.dart';
import '../../../l10n/app_localizations.dart';

class AddEditObjectScreen extends ConsumerStatefulWidget {
  // 1. 改为 ConsumerStatefulWidget
  final ObjectType objectType;
  final int? objectId; // 如果是编辑模式，则传入ID

  const AddEditObjectScreen({
    super.key,
    required this.objectType,
    this.objectId,
  });

  bool get isEditing => objectId != null;

  @override
  ConsumerState<AddEditObjectScreen> createState() =>
      _AddEditObjectScreenState(); // 2. 创建 State
}

class _AddEditObjectScreenState extends ConsumerState<AddEditObjectScreen> {
  // 3. 创建对应的 State 类
  final _formKey = GlobalKey<FormState>(); // 用于表单验证

  // 表单字段控制器
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController; // 仅宠物
  late TextEditingController _roomController; // 仅植物

  // 日期和枚举状态
  DateTime? _acquisitionDate; // 植物获取日期
  DateTime? _birthDate; // 宠物品种
  Gender? _gender; // 宠物性别
  DateTime _creationDate = DateTime.now(); // 记录的创建日期 (编辑时加载)

  // 图片状态
  String? _photoPath; // 存储选择的图片路径
  bool _isLoading = false; // 用于加载编辑数据或保存时的状态
  bool _isSaving = false; // 用于防止重复点击保存按钮

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _speciesController = TextEditingController();
    _breedController = TextEditingController();
    _roomController = TextEditingController();

    // 4. 如果是编辑模式，加载现有数据
    if (widget.isEditing) {
      _loadObjectData();
    }
  }

  // 5. 加载编辑数据的函数
  Future<void> _loadObjectData() async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider); // 获取数据库实例
    try {
      if (widget.objectType == ObjectType.plant) {
        final plant =
            await (db.select(db.plants)..where(
              (tbl) => tbl.id.equals(widget.objectId!),
            )).getSingleOrNull();
        if (plant != null && mounted) {
          setState(() {
            _nameController.text = plant.name;
            _nicknameController.text = plant.nickname ?? '';
            _speciesController.text = plant.species ?? '';
            _roomController.text = plant.room ?? '';
            _acquisitionDate = plant.acquisitionDate;
            _photoPath = plant.photoPath;
            _creationDate = plant.creationDate;
          });
        } else if (mounted) {
          _showErrorSnackBar(
            l10n.errorNotFound,
          ); // !! 使用 l10n !! (Or a specific message)
          context.pop();
        }
      } else {
        // Pet
        final pet =
            await (db.select(db.pets)..where(
              (tbl) => tbl.id.equals(widget.objectId!),
            )).getSingleOrNull();
        if (pet != null && mounted) {
          setState(() {
            _nameController.text = pet.name;
            _nicknameController.text = pet.nickname ?? '';
            _speciesController.text = pet.species ?? '';
            _breedController.text = pet.breed ?? '';
            _birthDate = pet.birthDate;
            _gender = pet.gender;
            _photoPath = pet.photoPath;
            _creationDate = pet.creationDate;
          });
        } else if (mounted) {
          _showErrorSnackBar(
            l10n.errorNotFound,
          ); // !! 使用 l10n !! (Or a specific message)
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(l10n.loadingFailed(e.toString())); // !! 使用 l10n !!
        context.pop();
      }
    } finally {
      if (mounted) {
        // 确保 widget 还在树中
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _nicknameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  // --- UI 构建 ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final title =
        widget.isEditing
            ? (widget.objectType == ObjectType.plant
                ? l10n.editPlant
                : l10n.editPet) // !! 使用 l10n !!
            : (widget.objectType == ObjectType.plant
                ? l10n.addPlant
                : l10n.addPet); // !! 使用 l10n !!

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // 保存按钮
          if (!_isLoading) // 加载时不显示保存按钮
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
              tooltip: l10n.save,
              onPressed: _isSaving ? null : _saveForm, // 防止重复点击
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // 加载时显示菊花
              : _buildForm(l10n), // 加载完成显示表单
    );
  }

  // 6. 构建表单 Widget
  Widget _buildForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      // 使表单可滚动
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildImagePicker(l10n), // 图片选择区域
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.name} *',
                hintText: 'Give it a name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${l10n.name}不能为空';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: l10n.nickname, // !! 使用 l10n !!
                hintText: l10n.optional,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _speciesController,
              decoration: InputDecoration(
                labelText: l10n.species, // !! 使用 l10n !!
                hintText: l10n.optional,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // --- 特定字段 ---
            if (widget.objectType == ObjectType.plant) ...[
              _buildDatePicker(
                context: context,
                l10n: l10n, // !! 传递 l10n !!
                label: l10n.acquisitionDate,
                selectedDate: _acquisitionDate,
                onDateSelected: (date) {
                  setState(() => _acquisitionDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: l10n.room, // !! 使用 l10n !!
                  hintText: '${l10n.optional} (例如：客厅)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ] else ...[
              // Pet fields
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: l10n.breed, // !! 使用 l10n !!
                  hintText: '${l10n.optional} (例如：金毛)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                context: context,
                l10n: l10n, // !! 传递 l10n !!
                label: l10n.birthDate,
                selectedDate: _birthDate,
                firstDate: DateTime(1990), // 宠物生日可选范围大些
                lastDate: DateTime.now(),
                onDateSelected: (date) {
                  setState(() => _birthDate = date);
                },
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(l10n), // 性别选择
            ],
            const SizedBox(height: 30),
            // 删除按钮 (仅编辑模式)
            if (widget.isEditing)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    '删除${widget.objectType == ObjectType.plant ? l10n.plants : l10n.pets}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _confirmDelete(l10n),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 7. 构建日期选择器
  Widget _buildDatePicker({
    required BuildContext context,
    required AppLocalizations l10n,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return InkWell(
      // 使整个区域可点击
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate:
              lastDate ??
              DateTime.now().add(const Duration(days: 365)), // 未来一年可选
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today), // 添加日历图标
        ),
        child: Text(
          selectedDate != null
              ? formatter.format(selectedDate)
              : l10n.selectDate,
          style: TextStyle(
            color:
                selectedDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 8. 构建性别选择器 (仅宠物)
  Widget _buildGenderSelector(AppLocalizations l10n) {
    return DropdownButtonFormField<Gender>(
      value: _gender,
      decoration: InputDecoration(
        labelText: l10n.gender,
        border: const OutlineInputBorder(),
      ),
      items:
          Gender.values.map((Gender gender) {
            String text;
            switch (gender) {
              case Gender.male:
                text = l10n.male;
                break; // !! 使用 l10n !!
              case Gender.female:
                text = l10n.female;
                break; // !! 使用 l10n !!
              case Gender.unknown:
                text = l10n.unknown;
                break; // !! 使用 l10n !!
            }
            return DropdownMenuItem<Gender>(value: gender, child: Text(text));
          }).toList(),
      onChanged: (Gender? newValue) {
        setState(() {
          _gender = newValue;
        });
      },
      // validator: (value) => value == null ? '请选择性别' : null, // 可以设为必填
    );
  }

  // 9. 构建图片选择器
  Widget _buildImagePicker(AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageSourceActionSheet(l10n),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _photoPath != null ? FileImage(File(_photoPath!)) : null,
              child:
                  _photoPath == null
                      ? Icon(
                        widget.objectType == ObjectType.plant
                            ? Icons.local_florist
                            : Icons.pets,
                        size: 50,
                        color: Colors.grey[400],
                      )
                      : null,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.image),
            label: Text(
              _photoPath != null ? '更换照片' : l10n.addPhotos.split(' ')[0],
            ), // !! 使用 l10n (简单处理) !!
            onPressed: () => _showImageSourceActionSheet(l10n),
          ),
        ],
      ),
    );
  }

  // !! 新增: 显示图片来源选择 (底部动作表单)
  void _showImageSourceActionSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          // 防止内容与系统 UI 重叠
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Album'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop(); // 关闭底部表单
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              // 可选: 添加移除照片选项 (如果已有照片)
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _photoPath = null; // 清除照片路径
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // 10. 图片选择逻辑
  Future<void> _getImage(ImageSource source) async {
    // <--- 修改点: 接收 source 参数
    final ImagePicker picker = ImagePicker();
    // 使用传入的 source 调用 pickImage
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 85, // 轻微压缩
      maxWidth: 1024, // 限制尺寸
    );

    if (image != null) {
      // 将图片保存到应用目录，防止源文件被删除
      final Directory appDir = await getApplicationDocumentsDirectory();
      // 创建更独特的文件名
      final String extension = p.extension(image.path); // 获取原始扩展名
      final String fileName =
          '${widget.objectType.name}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final String savedImagePath = p.join(appDir.path, fileName);

      try {
        // 删除旧照片 (如果存在且与新照片不同)
        if (_photoPath != null && _photoPath != savedImagePath) {
          final oldFile = File(_photoPath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
            print("Deleted old object photo: $_photoPath");
          }
        }

        final File imageFile = File(image.path);
        await imageFile.copy(savedImagePath);

        if (mounted) {
          setState(() {
            _photoPath = savedImagePath; // 更新状态以显示图片
          });
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackBar('Failed to save image: $e');
        }
      }
    }
  }

  // --- 保存与删除逻辑 ---

  // 11. 保存表单数据
  Future<void> _saveForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isSaving) return; // 防止重复提交

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // 触发 onSaved (如果需要)

      setState(() {
        _isSaving = true;
      });

      final db = ref.read(databaseProvider);
      final now = DateTime.now();

      try {
        if (widget.objectType == ObjectType.plant) {
          final plantCompanion = PlantsCompanion(
            // 如果是编辑，提供 id
            id:
                widget.isEditing
                    ? Value(widget.objectId!)
                    : const Value.absent(),
            name: Value(_nameController.text.trim()),
            nickname: Value(_nicknameController.text.trim()),
            species: Value(_speciesController.text.trim()),
            room: Value(_roomController.text.trim()),
            acquisitionDate: Value(_acquisitionDate),
            photoPath: Value(_photoPath),
            // 如果是添加，设置创建日期；如果是编辑，保持不变
            creationDate: Value(widget.isEditing ? _creationDate : now),
          );

          if (widget.isEditing) {
            await db.updatePlant(plantCompanion);
          } else {
            await db.insertPlant(plantCompanion);
          }
        } else {
          // Pet
          final petCompanion = PetsCompanion(
            id:
                widget.isEditing
                    ? Value(widget.objectId!)
                    : const Value.absent(),
            name: Value(_nameController.text.trim()),
            nickname: Value(_nicknameController.text.trim()),
            species: Value(_speciesController.text.trim()),
            breed: Value(_breedController.text.trim()),
            birthDate: Value(_birthDate),
            gender: Value(_gender),
            photoPath: Value(_photoPath),
            creationDate: Value(widget.isEditing ? _creationDate : now),
          );
          if (widget.isEditing) {
            await db.updatePet(petCompanion);
          } else {
            await db.insertPet(petCompanion);
          }
        }
        if (mounted) {
          // 保存成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.objectType == ObjectType.plant ? l10n.plants : l10n.pets}已${widget.isEditing ? '更新' : '添加'}',
              ),
            ),
          );

          // 返回上一页
          if (context.canPop()) context.pop();
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(l10n.errorSavingFailed(e.toString()));
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      // 表单验证失败提示
      _showErrorSnackBar('Please check form content');
    }
  }

  // 12. 确认删除对话框
  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final String itemTypeName =
        widget.objectType == ObjectType.plant
            ? l10n.plants
            : l10n.pets; // !! 获取类型名称 !!
    final String confirmationMessage =
        widget.objectType == ObjectType.plant
            ? l10n.deletePlantConfirmation
            : l10n.deletePetConfirmation; // !! 获取特定确认信息 !!
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeleteTitle),
          content: Text(confirmationMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop(false); // 返回 false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
              onPressed: () {
                Navigator.of(context).pop(true); // 返回 true
              },
            ),
          ],
        );
      },
    );

    // 如果用户确认删除
    if (result == true) {
      _deleteObject(l10n);
    }
  }

  // 13. 执行删除操作
  Future<void> _deleteObject(AppLocalizations l10n) async {
    if (!widget.isEditing || widget.objectId == null) return; // 只能在编辑模式删除

    setState(() {
      _isSaving = true;
    }); // 使用 isSaving 状态显示加载
    final db = ref.read(databaseProvider);

    try {
      // TODO: 未来需要级联删除相关的 LogEntries 和 Reminders
      // Drift 支持级联删除，需要在表定义中设置外键约束和 onDelete: KeyAction.cascade
      // 或者在这里手动删除：
      await (db.delete(db.logEntries)..where(
        (tbl) =>
            tbl.objectId.equals(widget.objectId!) &
            tbl.objectType.equals(widget.objectType.index),
      )).go();
      await (db.delete(db.reminders)..where(
        (tbl) =>
            tbl.objectId.equals(widget.objectId!) &
            tbl.objectType.equals(widget.objectType.index),
      )).go();
      if (_photoPath != null) {
        final photoFile = File(_photoPath!);
        if (await photoFile.exists()) {
          await photoFile.delete();
          print("Deleted object photo during object deletion: $_photoPath");
        }
      }

      if (widget.objectType == ObjectType.plant) {
        await db.deletePlant(widget.objectId!);
      } else {
        await db.deletePet(widget.objectId!);
      }

      // 删除成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.objectType == ObjectType.plant ? l10n.plants : l10n.pets}已删除',
          ),
        ),
      );

      // 返回列表页 (需要pop两次，一次是确认框，一次是编辑页)
      // 使用 go 可以直接回到列表页
      if (widget.objectType == ObjectType.plant) {
        context.goNamed(PlantListScreen.routeName);
      } else {
        context.goNamed(PetListScreen.routeName);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.errorDeletingFailed(e.toString()));
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    } finally {
      // if (mounted && _isSaving) { // 返回时页面已销毁
      //    // setState(() { _isSaving = false; });
      // }
    }
  }

  // --- 辅助函数 ---
  void _showErrorSnackBar(String message) {
    if (mounted) {
      // 检查 widget 是否还在树中
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
