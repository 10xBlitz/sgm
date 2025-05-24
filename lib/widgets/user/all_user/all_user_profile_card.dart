import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/widgets/user/all_user/all_user_details.dart';
import 'package:sgm/widgets/user/all_user/all_user_info_card.dart';
import 'package:sgm/widgets/user/user.project_pill.dart';
import 'package:sgm/widgets/user/user.status_badge.dart';
import 'package:sgm/widgets/user/user.user_avatar.dart';

class AllUserProfileCard extends StatelessWidget {
  final UserWithProjectsRow user;
  final List<UserRoleRow> availableRoles;

  const AllUserProfileCard({
    super.key,
    required this.user,
    required this.availableRoles,
  });

  @override
  Widget build(BuildContext context) {
    final projectNames = user.projectNames ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              children: [
                UserUserAvatar(userWithProjectsRow: user, size: 70),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Unnamed User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      UserStatusBadge(user: user),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projects',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  projectNames.isEmpty
                      ? const Text(
                        'No projects assigned',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            projectNames
                                .map(
                                  (project) =>
                                      UserProjectPill(projectName: project),
                                )
                                .toList(),
                      ),
                ],
              ),
            ),
            const Divider(),
            AllUserInfoCard(user: user, availableRoles: availableRoles),
            const Divider(),
            AllUserDetails(user: user),
          ],
        ),
      ),
    );
  }
}
