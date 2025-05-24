import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class AllUserActions extends StatelessWidget {
  final UserWithProjectsRow user;
  final Function(UserWithProjectsRow)? onUpdateRole;

  const AllUserActions({super.key, required this.user, this.onUpdateRole});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected:
          (value) => {
            if (value == 'update-role') {onUpdateRole?.call(user)},
          },
      itemBuilder:
          (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'update-role',
              child: Text('Update Role'),
            ),
            PopupMenuItem<String>(value: 'delete', child: Text('Delete User')),
          ],
    );
  }
}
