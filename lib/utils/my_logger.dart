import 'package:flutter/foundation.dart';

class MyLogger {
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('👉👉MyLogger: $message');
    }
  }

  static void e(String message) {
    if (kDebugMode) {
      debugPrint('⛔️⛔️ $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      debugPrint('⚠️⚠️ $message');
    }
  }
}
