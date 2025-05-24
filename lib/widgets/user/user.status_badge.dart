import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class UserStatusBadge extends StatelessWidget {
  final UserWithProjectsRow user;

  const UserStatusBadge({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    if (user.isBanned == true) {
      color = Colors.red;
      label = 'Banned';
      icon = Icons.block;
    } else if (user.acceptedAt == null) {
      color = Colors.orange;
      label = 'Pending';
      icon = Icons.access_time;
    } else {
      color = Colors.green;
      label = 'Active';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
