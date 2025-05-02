import 'package:flutter/material.dart';

class FormsTab extends StatelessWidget {
  static const String tabTitle = 'Forms';
  const FormsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
