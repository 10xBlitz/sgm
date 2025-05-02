import 'package:flutter/material.dart';

class ProceduresTab extends StatelessWidget {
  static const String tabTitle = 'Procedures';
  const ProceduresTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
