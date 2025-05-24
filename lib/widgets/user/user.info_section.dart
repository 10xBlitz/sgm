import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/utils/date/date_format.dart';

class UserInfoSection extends StatelessWidget {
  final UserRow user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name ?? 'No Name',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(user.email ?? 'No Email'),
        const SizedBox(height: 4),
        Text('Registered: ${formatDate(user.createdAt)}'),
      ],
    );
  }
}
