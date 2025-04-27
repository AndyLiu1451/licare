import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_pet_log/presentation/screens/gallery/photo_comparison_screen.dart'; // 引入对比页面
import '../../../models/enum.dart';
import '../../../models/photo_info.dart';
import '../../../providers/object_providers.dart'; // Or photo_providers.dart

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  // Use StatefulWidget for selection logic
  static const routeName = 'photoGallery';
  final int objectId;
  final ObjectType objectType;
  final String objectName; // Pass object name for AppBar title

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
  final List<PhotoInfo> _selectedPhotos =
      []; // Track selected photos for comparison
  bool _isSelectingMode = false; // Are we currently selecting photos?

  void _toggleSelection(PhotoInfo photo) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
        // If no photos are selected anymore, exit selection mode
        if (_selectedPhotos.isEmpty) {
          _isSelectingMode = false;
        }
      } else {
        // Allow selecting max 2 photos
        if (_selectedPhotos.length < 2) {
          _selectedPhotos.add(photo);
          _isSelectingMode =
              true; // Enter selection mode when first photo is selected
        } else {
          // Optional: Show a message that max 2 can be selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最多只能选择两张照片进行对比'),
              duration: Duration(seconds: 1),
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
      // Sort selected photos by date ascending
      _selectedPhotos.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
      context.pushNamed(
        // Use pushNamed to overlay comparison screen
        PhotoComparisonScreen.routeName,
        extra: {
          'photo1': _selectedPhotos[0],
          'photo2': _selectedPhotos[1],
          'objectName': widget.objectName,
        },
      );
      // Optionally clear selection after navigation? Or keep it?
      // _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPhotos = ref.watch(
      objectPhotosProvider((
        objectId: widget.objectId,
        objectType: widget.objectType,
      )),
    );
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectingMode
              ? '选择照片 (${_selectedPhotos.length}/2)'
              : '${widget.objectName} - 照片墙',
        ),
        leading:
            _isSelectingMode
                ? IconButton(
                  // Show cancel selection button
                  icon: const Icon(Icons.close),
                  tooltip: '取消选择',
                  onPressed: _clearSelection,
                )
                : null, // Default back button appears otherwise
        actions: [
          // Show "Compare" button only when exactly 2 photos are selected
          if (_isSelectingMode && _selectedPhotos.length == 2)
            TextButton(
              onPressed: _navigateToComparison,
              child: const Text(
                '对比',
                style: TextStyle(color: Colors.white),
              ), // Adjust color if needed
            ),
          // Optional: Add button to explicitly enter selection mode?
          // else if (!_isSelectingMode && asyncPhotos.hasValue && asyncPhotos.value!.length >= 2)
          //    IconButton(
          //       icon: const Icon(Icons.compare_arrows),
          //       tooltip: '选择照片对比',
          //       onPressed: () => setState(() => _isSelectingMode = true),
          //    )
        ],
      ),
      body: asyncPhotos.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text('还没有任何照片记录'));
          }
          // 使用 GridView 显示照片墙
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 每行显示3张照片
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
                    _toggleSelection(
                      photo,
                    ); // Toggle selection in selection mode
                  } else {
                    // TODO: Implement full screen image view on tap?
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImageView(photo: photo)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '查看大图功能待实现 - ${formatter.format(photo.dateTaken)}',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  // Use long press to enter selection mode and select first photo
                  if (!_isSelectingMode) {
                    _toggleSelection(photo);
                  }
                },
                child: GridTile(
                  footer: Container(
                    // Simple footer showing date
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      formatter.format(photo.dateTaken),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: Stack(
                    // Use Stack for selection overlay
                    fit: StackFit.expand,
                    children: [
                      // Image
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
                      // Selection Overlay
                      if (isSelected)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      // Or add border for selection:
                      // if (isSelected)
                      //   Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Theme.of(context).primaryColor, width: 3)
                      //     ),
                      //   )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载照片失败: $error')),
      ),
    );
  }
}
