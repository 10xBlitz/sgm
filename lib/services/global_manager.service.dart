import 'package:flutter/material.dart';

/// A singleton service that manages snackbar displays throughout the app.
class GlobalManagerService {
  // Singleton instance
  static final GlobalManagerService _instance =
      GlobalManagerService._internal();

  // Private constructor
  GlobalManagerService._internal();

  // Factory constructor to return the same instance
  factory GlobalManagerService() => _instance;

  BuildContext? _globalContext;

  void setGlobalContextIfNull(BuildContext context) {
    if (_globalContext != null) return;
    _globalContext = context;
  }

  /// Shows a standard snackbar with the given message.
  ///
  /// Uses a floating snackbar with a 2-second duration.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
    BuildContext? context,
    String message,
  ) {
    return ScaffoldMessenger.of(_globalContext ?? context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        showCloseIcon: true,
      ),
    );
  }

  /// Shows an error snackbar with the given message.
  ///
  /// Uses a floating snackbar with error styling and a 5-second duration.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbarError(
    BuildContext? context,
    String message,
  ) {
    final colorScheme = Theme.of(context ?? _globalContext!).colorScheme;
    return ScaffoldMessenger.of(_globalContext ?? context!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: colorScheme.errorContainer,
        showCloseIcon: true,
        closeIconColor: colorScheme.onErrorContainer,
      ),
    );
  }
}
