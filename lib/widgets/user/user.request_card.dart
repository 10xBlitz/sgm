import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/user.info_section.dart';

class UserRequestCard extends StatefulWidget {
  final UserRow user;
  final Function(String, String?) onRoleChanged;
  final Function(String) onApproved;
  final Function(String) onReject;

  const UserRequestCard({
    super.key,
    required this.user,
    required this.onRoleChanged,
    required this.onApproved,
    required this.onReject,
  });

  @override
  State<UserRequestCard> createState() => _UserRequestCardState();
}

class _UserRequestCardState extends State<UserRequestCard> {
  UserService userService = UserService();
  String? _selectedRole;
  List<UserRoleRow> availableRoles = [];
  bool isApproved = false;
  bool hasRole = false;
  bool hasRejected = false;

  @override
  void initState() {
    super.initState();

    isApproved = widget.user.acceptedAt != null;
    hasRole = widget.user.role != null;
    hasRejected = widget.user.rejectedAt != null;

    loadUserRole();
  }

  void loadUserRole() async {
    availableRoles = await userService.fetchUserRolesWithCache();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserInfoSection(user: widget.user),
            const SizedBox(height: 16),
            if (isApproved)
              RoleDropdown(
                selectedRole: _selectedRole,
                availableRoles: availableRoles,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            const SizedBox(height: 14),
            ActionButton(
              hasRejected: hasRejected,
              isApproved: isApproved,
              onApproved: () {
                widget.onApproved(widget.user.id);
              },
              hasRole: hasRole,
              selectedRole: _selectedRole,
              onPressed: () {
                widget.onRoleChanged(widget.user.id, _selectedRole);
              },
              onReject: () {
                widget.onReject(widget.user.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleDropdown extends StatelessWidget {
  final String? selectedRole;
  final List<UserRoleRow> availableRoles;
  final Function(String?) onChanged;

  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.availableRoles,
    required this.onChanged,
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
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final bool isApproved;
  final bool hasRole;
  final bool hasRejected;
  final String? selectedRole;
  final VoidCallback onPressed;
  final VoidCallback onApproved;
  final VoidCallback onReject;

  const ActionButton({
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
