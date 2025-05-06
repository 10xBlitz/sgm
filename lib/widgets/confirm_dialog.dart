import 'package:flutter/material.dart';

/// A dialog that asks the user to confirm or cancel an action
/// Returns true when confirmed, false when canceled
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  });

  final String? title;
  final String? message;
  final String confirmText;
  final String cancelText;

  /// Shows the confirm dialog and returns true if confirmed, false otherwise
  static Future<bool> show({
    required BuildContext context,
    String? title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
          ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20.0, 0.0, 0.0),
                    child: Text(title!, style: theme.textTheme.titleLarge),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Message
                if (message != null)
                  Text(message!, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelText),
                    ),

                    const SizedBox(width: 16),

                    // Confirm button
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
