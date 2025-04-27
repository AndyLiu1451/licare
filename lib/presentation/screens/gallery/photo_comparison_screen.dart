import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/photo_info.dart';
// Optional: Import interactive_viewer for zoom/pan
// import 'package:interactive_viewer_gallery/interactive_viewer_gallery.dart';

class PhotoComparisonScreen extends StatelessWidget {
  static const routeName = 'photoComparison';
  final PhotoInfo photo1;
  final PhotoInfo photo2;
  final String objectName;

  const PhotoComparisonScreen({
    super.key,
    required this.photo1,
    required this.photo2,
    required this.objectName,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('$objectName - 成长对比')),
      body: Column(
        // Use Column for side-by-side layout
        children: [
          Expanded(
            // Use Expanded to fill available space
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Photo
                Expanded(
                  child: _buildComparisonItem(
                    context,
                    photo1,
                    formatter,
                    theme,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1), // Separator
                // Right Photo
                Expanded(
                  child: _buildComparisonItem(
                    context,
                    photo2,
                    formatter,
                    theme,
                  ),
                ),
              ],
            ),
          ),
          // Optional: Add a slider or other controls for overlay/diff view later
          // Padding(
          //    padding: const EdgeInsets.all(16.0),
          //    child: Slider(...),
          // )
        ],
      ),
    );
  }

  // Helper widget to build one side of the comparison
  Widget _buildComparisonItem(
    BuildContext context,
    PhotoInfo photo,
    DateFormat formatter,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formatter.format(photo.dateTaken), // Show date
            style: theme.textTheme.titleMedium,
          ),
          if (photo.sourceType == PhotoSourceType.logEntry &&
              photo.logEventType != null)
            Text(
              photo.logEventType!, // Show log event type if available
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Expanded(
            // Image takes remaining space
            child: ClipRRect(
              // Optional: rounded corners
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(photo.filePath),
                fit: BoxFit.contain, // Use contain to see the whole image
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '无法加载图片',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            // --- Optional: Using InteractiveViewer for Zoom/Pan ---
            // child: InteractiveViewer(
            //   panEnabled: true,
            //   minScale: 1.0,
            //   maxScale: 4.0,
            //   child: ClipRRect(
            //      borderRadius: BorderRadius.circular(8.0),
            //      child: Image.file(...) // Image widget inside
            //   ),
            // ),
            // --- End Optional InteractiveViewer ---
          ),
        ],
      ),
    );
  }
}
