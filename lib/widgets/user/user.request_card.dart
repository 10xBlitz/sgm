import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/user.info_section.dart';
import 'package:sgm/widgets/user/user.request_action_buttons.dart';
import 'package:sgm/widgets/user/user.role_dropdown.dart';

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
    if (widget.user.isBanned == true) {
      return SizedBox.shrink();
    }

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
              UserRoleDropDown(
                selectedRole: _selectedRole,
                availableRoles: availableRoles,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            const SizedBox(height: 14),
            UserRequestActionButton(
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
