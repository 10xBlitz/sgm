import 'package:flutter/material.dart';
import 'package:sgm/extensions/responsive.extension.dart';
import 'package:sgm/mainTabs/chat/widgets/chat_room.list_view.dart';
import 'package:sgm/mainTabs/chat/widgets/chat_room.view.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room.row.dart';

class ChatTab extends StatefulWidget {
  static const String tabTitle = 'Chat';
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return ChatRoomListView(
      onChatRoomTap: (ChatRoomRow chatRoom) {
        // Open the Chatroom as full screen dialog
        showGeneralDialog(
          context: context,
          pageBuilder: (context, a1, a2) {
            return ChatRoomView(
              chatRoom: chatRoom,
              onBack: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }
}
