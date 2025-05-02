import 'package:flutter/material.dart';

class ProjectsTab extends StatelessWidget {
  static const String tabTitle = 'Projects';
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
