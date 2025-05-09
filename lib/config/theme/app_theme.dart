import 'package:flutter/material.dart';

const Color _customColor = Color(0xFF4CAF50); // 定义一个主色调 (绿色)
const List<Color> _colorThemes = [
  _customColor,
  Colors.blue,
  Colors.teal,
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
    : assert(
        selectedColor >= 0 && selectedColor < _colorThemes.length,
        'Selected color must be between 0 and ${_colorThemes.length - 1}',
      );

  // 获取颜色列表供外部使用 (例如设置页)
  static List<Color> get colorThemes => _colorThemes;

  // 生成 ThemeData 的核心方法
  ThemeData themeData({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _colorThemes[selectedColor],
      brightness: brightness, // !! 根据传入的亮度生成配色方案
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme, // 使用生成的配色方案
      brightness: brightness, // 设置整体亮度
      // --- 可选: 针对不同模式微调组件样式 ---
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor:
            brightness == Brightness.dark
                ? colorScheme.surface
                : colorScheme.primary, // 深色用 surface，浅色用 primary
        foregroundColor:
            brightness == Brightness.dark
                ? colorScheme.onSurface
                : colorScheme.onPrimary, // 相应的前景色
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        // <--- 设置为悬浮模式
        // 可以添加其他 SnackBar 样式，例如边距、形状、背景色等
        // backgroundColor: brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[800], // 可选：自定义背景色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), // 可选：圆角
        // floatingSnackBarTheme 需要 elevation 吗？可能不需要
        // elevation: 4.0, // 可选：阴影
        // contentTextStyle: TextStyle(color: Colors.white), // 可选：内容文字颜色
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // 可以根据 brightness 调整选中/未选中颜色，但 colorScheme 通常能处理好
        selectedItemColor: colorScheme.primary,
        // unselectedItemColor: Colors.grey, // 可以保持不变或微调
        // backgroundColor: brightness == Brightness.dark ? colorScheme.surfaceVariant : null, // 深色模式下给导航栏一点颜色区分
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        // Fix: Changed CardTheme to CardThemeData
        elevation: brightness == Brightness.light ? 1.0 : 2.0, // 深色模式卡片阴影可以明显一点
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ), // 统一卡片边距
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 可选：圆角卡片
      ),
      listTileTheme: ListTileThemeData(
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 可选：配合卡片圆角
        // selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5), // 可选：选中项颜色
      ),
      // ... 其他组件主题定制 (Switch, Chip, Dialog etc.)
    );
  }

  // // (旧方法，可以移除或保留用于简化调用)
  // ThemeData getTheme() => themeData(brightness: Brightness.light);
}
