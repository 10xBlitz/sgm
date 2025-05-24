import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/widgets/user/all_user/all_user.Info.dart';
import 'package:sgm/widgets/user/all_user/all_user_actions.dart';
import 'package:sgm/widgets/user/user.user_avatar.dart';

class AllUserCard extends StatelessWidget {
  final UserWithProjectsRow user;
  final List<UserRoleRow> availableRoles;
  final Function(UserWithProjectsRow) onUpdateRole;

  const AllUserCard({
    super.key,
    required this.user,
    required this.availableRoles,
    required this.onUpdateRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            UserUserAvatar(userWithProjectsRow: user),
            const SizedBox(width: 16),
            Expanded(
              child: AllUserInfo(user: user, availableRoles: availableRoles),
            ),
            AllUserActions(user: user, onUpdateRole: (p0) => onUpdateRole(p0)),
          ],
        ),
      ),
    );
  }
}
