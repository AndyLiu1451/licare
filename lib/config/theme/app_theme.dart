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

  ThemeData getTheme() => ThemeData(
    useMaterial3: true, // 启用 Material 3 风格
    colorSchemeSeed: _colorThemes[selectedColor],
    brightness: Brightness.light, // 默认浅色模式
    // 可以进一步自定义 AppBarTheme, TextTheme 等
    appBarTheme: const AppBarTheme(
      centerTitle: true, // 标题居中 (可选)
      elevation: 2,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _customColor, // 选中项颜色
      unselectedItemColor: Colors.grey, // 未选中项颜色
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _customColor,
      foregroundColor: Colors.white,
    ),
    // ... 其他主题定制
  );
}
