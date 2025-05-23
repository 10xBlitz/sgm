import 'package:flutter/material.dart';
import 'package:sgm/screens/user/user.management.screen.dart';

class UserManagementTab extends StatelessWidget {
  static const String tabTitle = 'User Management';
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return UserManagementScreen();
  }
}
