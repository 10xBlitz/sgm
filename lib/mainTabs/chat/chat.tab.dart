import 'package:flutter/material.dart';
import 'package:sgm/mainTabs/chat/widgets/chat_room.list_view.dart';

class ChatTab extends StatelessWidget {
  static const String tabTitle = 'Chat';
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChatRoomListView(),
        ),
      ],
    );
  }
}
