import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing app theme
/// 
/// StateProvider is perfect for simple boolean toggles like dark mode.
/// This demonstrates how to use Riverpod for UI state beyond just data.
final isDarkModeProvider = StateProvider<bool>((ref) {
  return false; // Default to light mode
});

/// Computed provider for the actual theme data
/// 
/// This shows how to create derived state from simple values.
/// When isDarkModeProvider changes, this automatically recalculates.
final themeDataProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ),
    useMaterial3: true,
  );
}); 