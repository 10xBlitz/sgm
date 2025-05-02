import 'package:flutter/material.dart';

class MyTaskTab extends StatelessWidget {
  static const String tabTitle = 'My Tasks';
  const MyTaskTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
