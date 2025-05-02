import 'package:flutter/material.dart';

class UserManagementTab extends StatelessWidget {
  static const String tabTitle = 'User Management';
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
