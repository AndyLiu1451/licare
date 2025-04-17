import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences Keys
const String _prefSelectedColorIndex = 'selectedColorIndex';
const String _prefThemeMode = 'themeMode'; // Store ThemeMode enum index

// --- Theme State Model --- (Optional but good practice)
// class ThemeState {
//   final int selectedColorIndex;
//   final ThemeMode themeMode;
//   ThemeState({required this.selectedColorIndex, required this.themeMode});
// }

// --- Theme Notifier ---
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // State is now just ThemeMode
  final SharedPreferences _prefs;
  final StateController<int> _colorController; // Controller for color index

  ThemeNotifier(this._prefs, this._colorController)
    : super(_loadThemeMode(_prefs)); // Load initial ThemeMode

  // Helper to load initial ThemeMode
  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final int themeIndex =
        prefs.getInt(_prefThemeMode) ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  // Method to change ThemeMode
  void changeThemeMode(ThemeMode mode) {
    if (state != mode) {
      state = mode;
      _prefs.setInt(_prefThemeMode, mode.index); // Persist change
    }
  }

  // Method to change Color (delegated via StateController)
  void changeColorIndex(int index) {
    _colorController.state = index; // Update color state
    _prefs.setInt(_prefSelectedColorIndex, index); // Persist color change
  }
}

// --- Riverpod Providers ---

// Provider for the selected color index (simple StateProvider)
final selectedColorIndexProvider = StateProvider<int>((ref) {
  // Load initial color index from SharedPreferences
  // Need SharedPreferences instance here. We can create a provider for it.
  final prefs = ref.watch(
    sharedPreferencesProvider,
  ); // Depend on SharedPreferences provider
  return prefs.getInt(_prefSelectedColorIndex) ??
      0; // Default to 0 (first color)
});

// Provider for the SharedPreferences instance (async)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will throw during the first frame if accessed immediately,
  // but ThemeNotifier and selectedColorIndexProvider will likely access it later.
  // Or use FutureProvider if needed earlier.
  throw UnimplementedError(
    'SharedPreferences should be overridden in main.dart',
  );
});

// Provider for the ThemeNotifier (manages ThemeMode and interacts with color)
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider); // Get SharedPreferences
  final colorController = ref.watch(
    selectedColorIndexProvider.notifier,
  ); // Get color StateController
  return ThemeNotifier(prefs, colorController);
});
