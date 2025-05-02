import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  static const String tabTitle = 'Chat';
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}
