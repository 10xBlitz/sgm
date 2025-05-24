import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/widgets/user/all_user/all_user.info_item.dart';

class AllUserInfoCard extends StatelessWidget {
  final UserWithProjectsRow user;
  final List<UserRoleRow> availableRoles;

  const AllUserInfoCard({
    super.key,
    required this.user,
    required this.availableRoles,
  });

  String _getRoleName() {
    if (user.role == null) return 'No role assigned';

    final role = availableRoles.firstWhere((role) => role.id == user.role);

    return role.name;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 0.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InfoItem(label: 'Name', value: user.name ?? 'Not provided'),
          const Divider(),
          InfoItem(label: 'Email', value: user.email ?? 'Not provided'),
          const Divider(),
          InfoItem(label: 'Role', value: _getRoleName()),
          const Divider(),
          InfoItem(label: 'Join Date', value: _formatDate(user.createdAt)),
          const Divider(),
          InfoItem(
            label: 'Status',
            value:
                user.isBanned == true
                    ? 'Banned'
                    : user.acceptedAt == null
                    ? 'Pending Approval'
                    : 'Active',
          ),
        ],
      ),
    );
  }
}
