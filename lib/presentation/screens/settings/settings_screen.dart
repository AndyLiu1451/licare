import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = 'settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(child: Text('设置选项将在这里显示')),
    );
  }
}
