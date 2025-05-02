import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  static const String tabTitle = 'Dashboard';
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
