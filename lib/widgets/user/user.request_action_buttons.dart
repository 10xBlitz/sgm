import 'package:flutter/material.dart';

class UserRequestActionButton extends StatelessWidget {
  final bool isApproved;
  final bool hasRole;
  final bool hasRejected;
  final String? selectedRole;
  final VoidCallback onPressed;
  final VoidCallback onApproved;
  final VoidCallback onReject;

  const UserRequestActionButton({
    super.key,
    required this.isApproved,
    required this.hasRole,
    required this.selectedRole,
    required this.onPressed,
    required this.onApproved,
    required this.onReject,
    required this.hasRejected,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText;
    bool isEnabled;

    if (!isApproved) {
      buttonText = 'Approve';
      isEnabled = true;
    } else if (!hasRole) {
      buttonText = 'Assign Role';
      isEnabled = selectedRole != null;
    } else {
      buttonText = 'Update Role';
      isEnabled = selectedRole != null;
    }

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
            onPressed:
                isEnabled
                    ? !isApproved
                        ? onApproved
                        : onPressed
                    : null,
            child: Text(buttonText),
          ),
        ),
        if (!isApproved && !hasRejected)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: onReject,
              child: const Text('Reject'),
            ),
          ),
      ],
    );
  }
}
