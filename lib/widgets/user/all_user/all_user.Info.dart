import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class AllUserInfo extends StatelessWidget {
  final UserWithProjectsRow user;
  final List<UserRoleRow> availableRoles;

  const AllUserInfo({
    super.key,
    required this.user,
    required this.availableRoles,
  });

  String getRoleName(String? roleId) {
    final role = availableRoles.firstWhere((role) => role.id == roleId);
    return role.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name ?? 'Unknown',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'No email',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          'Role:  ${user.role != null ? getRoleName(user.role) : 'No role assigned'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
