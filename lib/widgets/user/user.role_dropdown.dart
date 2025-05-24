import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';

class UserRoleDropDown extends StatelessWidget {
  final String? selectedRole;
  final List<UserRoleRow> availableRoles;
  final Function(String?) onChanged;
  final bool showReset;
  final VoidCallback? onReset;

  const UserRoleDropDown({
    super.key,
    required this.selectedRole,
    required this.availableRoles,
    required this.onChanged,
    this.showReset = false,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Assign Role',
              border: OutlineInputBorder(),
            ),
            value: selectedRole,
            hint: const Text('Select a role'),
            items:
                availableRoles
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role.id,
                        child: Text(role.name),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
          ),
        ),
        if (showReset && onReset != null) ...[
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onReset,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ],
    );
  }
}
