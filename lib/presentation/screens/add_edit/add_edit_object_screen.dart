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
    setState(() {
      _isLoading = true;
    });
    final db = ref.read(databaseProvider); // 获取数据库实例
    try {
      if (widget.objectType == ObjectType.plant) {
        final plant =
            await (db.select(db.plants)..where(
              (tbl) => tbl.id.equals(widget.objectId!),
            )).getSingleOrNull();
        if (plant != null) {
          _nameController.text = plant.name;
          _nicknameController.text = plant.nickname ?? '';
          _speciesController.text = plant.species ?? '';
          _roomController.text = plant.room ?? '';
          _acquisitionDate = plant.acquisitionDate;
          _photoPath = plant.photoPath;
          _creationDate = plant.creationDate; // 保留原始创建日期
        } else {
          // 处理找不到对象的情况
          _showErrorSnackBar('找不到植物数据');
          context.pop(); // 返回上一页
        }
      } else {
        // Pet
        final pet =
            await (db.select(db.pets)..where(
              (tbl) => tbl.id.equals(widget.objectId!),
            )).getSingleOrNull();
        if (pet != null) {
          _nameController.text = pet.name;
          _nicknameController.text = pet.nickname ?? '';
          _speciesController.text = pet.species ?? '';
          _breedController.text = pet.breed ?? '';
          _birthDate = pet.birthDate;
          _gender = pet.gender;
          _photoPath = pet.photoPath;
          _creationDate = pet.creationDate;
        } else {
          _showErrorSnackBar('找不到宠物数据');
          context.pop();
        }
      }
    } catch (e) {
      _showErrorSnackBar('加载数据失败: $e');
      context.pop();
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
    final title =
        widget.isEditing
            ? (widget.objectType == ObjectType.plant ? '编辑植物' : '编辑宠物')
            : (widget.objectType == ObjectType.plant ? '添加植物' : '添加宠物');

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
              tooltip: '保存',
              onPressed: _isSaving ? null : _saveForm, // 防止重复点击
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // 加载时显示菊花
              : _buildForm(), // 加载完成显示表单
    );
  }

  // 6. 构建表单 Widget
  Widget _buildForm() {
    return SingleChildScrollView(
      // 使表单可滚动
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildImagePicker(), // 图片选择区域
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称 *',
                hintText: '给它取个名字吧',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '名称不能为空';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                hintText: '(可选)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _speciesController,
              decoration: InputDecoration(
                labelText:
                    widget.objectType == ObjectType.plant ? '品种/学名' : '品种',
                hintText: '(可选)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // --- 特定字段 ---
            if (widget.objectType == ObjectType.plant) ...[
              _buildDatePicker(
                context: context,
                label: '获取日期',
                selectedDate: _acquisitionDate,
                onDateSelected: (date) {
                  setState(() => _acquisitionDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: '放置位置',
                  hintText: '例如：客厅、阳台 (可选)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ] else ...[
              // Pet fields
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: '具体品种',
                  hintText: '例如：金毛、布偶 (可选)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                context: context,
                label: '生日',
                selectedDate: _birthDate,
                firstDate: DateTime(1990), // 宠物生日可选范围大些
                lastDate: DateTime.now(),
                onDateSelected: (date) {
                  setState(() => _birthDate = date);
                },
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(), // 性别选择
            ],
            const SizedBox(height: 30),
            // 删除按钮 (仅编辑模式)
            if (widget.isEditing)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    '删除${widget.objectType == ObjectType.plant ? '植物' : '宠物'}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: _confirmDelete,
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
          selectedDate != null ? formatter.format(selectedDate) : '(未选择)',
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
  Widget _buildGenderSelector() {
    return DropdownButtonFormField<Gender>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: '性别',
        border: OutlineInputBorder(),
      ),
      items:
          Gender.values.map((Gender gender) {
            String text;
            switch (gender) {
              case Gender.male:
                text = '雄性';
                break;
              case Gender.female:
                text = '雌性';
                break;
              case Gender.unknown:
                text = '未知';
                break;
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
  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
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
            label: Text(_photoPath != null ? '更换照片' : '添加照片'),
            onPressed: _pickImage,
          ),
        ],
      ),
    );
  }

  // 10. 图片选择逻辑
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    ); // 或 ImageSource.camera

    if (image != null) {
      // 将图片保存到应用目录，防止源文件被删除
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String savedImagePath = p.join(appDir.path, fileName);

      try {
        final File imageFile = File(image.path);
        await imageFile.copy(savedImagePath);
        if (mounted) {
          setState(() {
            _photoPath = savedImagePath; // 更新状态以显示图片
          });
        }
      } catch (e) {
        _showErrorSnackBar('保存图片失败: $e');
      }
    }
  }

  // --- 保存与删除逻辑 ---

  // 11. 保存表单数据
  Future<void> _saveForm() async {
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

        // 保存成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.objectType == ObjectType.plant ? '植物' : '宠物'}已${widget.isEditing ? '更新' : '添加'}',
            ),
          ),
        );

        // 返回上一页
        if (context.canPop()) context.pop();
      } catch (e) {
        _showErrorSnackBar('保存失败: $e');
        setState(() {
          _isSaving = false;
        }); // 出错时允许重试
      } finally {
        // 确保在异步操作后如果 widget 还在树中，则更新状态
        if (mounted && _isSaving) {
          // 只有在未出错时才将 _isSaving 设回 false (因为出错时已设置)
          // setState(() { _isSaving = false; }); // 返回时页面已销毁，无需再设置
        }
      }
    } else {
      // 表单验证失败提示
      _showErrorSnackBar('请检查表单内容');
    }
  }

  // 12. 确认删除对话框
  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除?'),
          content: Text(
            '确定要删除这个${widget.objectType == ObjectType.plant ? '植物' : '宠物'}吗？相关的日志和提醒也会一并删除。此操作无法撤销。',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false); // 返回 false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
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
      _deleteObject();
    }
  }

  // 13. 执行删除操作
  Future<void> _deleteObject() async {
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

      if (widget.objectType == ObjectType.plant) {
        await db.deletePlant(widget.objectId!);
      } else {
        await db.deletePet(widget.objectId!);
      }

      // 删除成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.objectType == ObjectType.plant ? '植物' : '宠物'}已删除',
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
      _showErrorSnackBar('删除失败: $e');
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
