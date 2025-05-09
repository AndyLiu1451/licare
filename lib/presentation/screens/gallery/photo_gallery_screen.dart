// lib/presentation/screens/gallery/photo_gallery_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_pet_log/presentation/screens/gallery/photo_comparison_screen.dart';
import '../../../models/enum.dart';
import '../../../models/photo_info.dart';
import '../../../providers/object_providers.dart';
// !! 引入生成的本地化类 !!
import '../../../l10n/app_localizations.dart';

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  static const routeName = 'photoGallery';
  final int objectId;
  final ObjectType objectType;
  final String objectName;

  const PhotoGalleryScreen({
    super.key,
    required this.objectId,
    required this.objectType,
    required this.objectName,
  });

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  final List<PhotoInfo> _selectedPhotos = [];
  bool _isSelectingMode = false;

  void _toggleSelection(PhotoInfo photo) {
    final l10n = AppLocalizations.of(context)!; // 获取 l10n 实例
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
        if (_selectedPhotos.isEmpty) {
          _isSelectingMode = false;
        }
      } else {
        if (_selectedPhotos.length < 2) {
          _selectedPhotos.add(photo);
          _isSelectingMode = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // !! 使用 l10n !!
              content: Text(l10n.maxPhotosSelected),
              duration: const Duration(seconds: 1), // 缩短显示时间
            ),
          );
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPhotos.clear();
      _isSelectingMode = false;
    });
  }

  void _navigateToComparison() {
    if (_selectedPhotos.length == 2) {
      _selectedPhotos.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
      context.pushNamed(
        PhotoComparisonScreen.routeName,
        extra: {
          'photo1': _selectedPhotos[0],
          'photo2': _selectedPhotos[1],
          'objectName': widget.objectName,
        },
      );
      // _clearSelection(); // 对比后保持选择状态可能更好
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // !! 获取 l10n !!
    final asyncPhotos = ref.watch(
      objectPhotosProvider((
        objectId: widget.objectId,
        objectType: widget.objectType,
      )),
    );
    final DateFormat formatter = DateFormat('yyyy-MM-dd'); // 这个日期格式通常不需要本地化

    return Scaffold(
      appBar: AppBar(
        // !! 使用 l10n 和占位符 !!
        title: Text(
          _isSelectingMode
              ? l10n.selectPhotos(
                // 使用带占位符的方法
                _selectedPhotos.length,
              )
              : '${widget.objectName} - ${l10n.photoGallery}', // 组合字符串
        ),
        leading:
            _isSelectingMode
                ? IconButton(
                  icon: const Icon(Icons.close),
                  // !! 使用 l10n !!
                  tooltip: l10n.cancelSelection,
                  onPressed: _clearSelection,
                )
                : null,
        actions: [
          if (_isSelectingMode && _selectedPhotos.length == 2)
            TextButton(
              onPressed: _navigateToComparison,
              child: Text(
                // !! 使用 l10n !!
                l10n.compare,
                // 保持白色，或根据 AppBar 主题调整
                style: TextStyle(
                  color:
                      Theme.of(context).appBarTheme.foregroundColor ??
                      Colors.white,
                ),
              ),
            ),
          // Optional button to enter selection mode - tooltip needs localization if added
        ],
      ),
      body: asyncPhotos.when(
        data: (photos) {
          if (photos.isEmpty) {
            // !! 使用 l10n !!
            return Center(child: Text(l10n.noPhotos));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final isSelected = _selectedPhotos.contains(photo);

              return GestureDetector(
                onTap: () {
                  if (_isSelectingMode) {
                    _toggleSelection(photo);
                  } else {
                    // TODO: Implement full screen image view on tap?
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        // !! 使用 l10n !! (需要一个新的 key)
                        content: Text(
                          l10n.viewFullScreen,
                        ), // 假设你添加了 viewFullScreen key
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  if (!_isSelectingMode) {
                    _toggleSelection(photo);
                  }
                },
                child: GridTile(
                  footer: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      formatter.format(photo.dateTaken), // 日期格式通常保持不变
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.filePath),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                      if (isSelected)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // !! 使用 l10n 和占位符 !!
        error:
            (error, stack) =>
                Center(child: Text(l10n.loadingFailed(error.toString()))),
      ),
    );
  }
}
