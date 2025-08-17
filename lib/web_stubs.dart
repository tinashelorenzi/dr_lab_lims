// lib/web_stubs.dart
// Stub file for web platform to avoid window_manager dependency

import 'package:flutter/material.dart';

// Stub classes and objects for web compatibility
class WindowManager {
  Future<void> ensureInitialized() async {
    // No-op for web
  }
  
  Future<void> waitUntilReadyToShow(WindowOptions options, Function callback) async {
    // No-op for web
  }
  
  Future<void> show() async {
    // No-op for web
  }
  
  Future<void> focus() async {
    // No-op for web
  }
}

class WindowOptions {
  final Size size;
  final Size minimumSize;
  final bool center;
  final Color backgroundColor;
  final bool skipTaskbar;
  final TitleBarStyle titleBarStyle;
  final String title;
  
  const WindowOptions({
    required this.size,
    required this.minimumSize,
    required this.center,
    required this.backgroundColor,
    required this.skipTaskbar,
    required this.titleBarStyle,
    required this.title,
  });
}

enum TitleBarStyle {
  normal,
}

// Export the stub instance
final windowManager = WindowManager();