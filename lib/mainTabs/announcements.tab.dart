import 'package:flutter/material.dart';

class AnnouncementsTab extends StatelessWidget {
  static const String tabTitle = 'Announcements';
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
