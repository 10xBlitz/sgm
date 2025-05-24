import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class UpdateRoleDialog extends StatefulWidget {
  final UserWithProjectsRow user;
  final List<UserRoleRow> availableRoles;
  final Function(String?) onRoleSelected;

  const UpdateRoleDialog({
    super.key,
    required this.user,
    required this.availableRoles,
    required this.onRoleSelected,
  });

  @override
  State<UpdateRoleDialog> createState() => _UpdateRoleDialogState();
}

class _UpdateRoleDialogState extends State<UpdateRoleDialog> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  String _getRoleName(String? roleId) {
    if (roleId == null) return 'Unknown Role';

    final role = widget.availableRoles.firstWhere((r) => r.id == roleId);

    return role.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update User Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User: ${widget.user.name ?? 'Unknown'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Current role: ${_getRoleName(widget.user.role)}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select New Role',
              border: OutlineInputBorder(),
            ),
            value: _selectedRole,
            items:
                widget.availableRoles
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role.id,
                        child: Text(role.name),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
              widget.onRoleSelected(_selectedRole);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedRole != widget.user.role
                  ? () {
                    Navigator.of(context).pop();
                  }
                  : null,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
