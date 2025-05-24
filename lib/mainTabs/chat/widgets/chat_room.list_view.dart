import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room.row.dart';
import 'package:sgm/services/chat_room.service.dart';

class ChatRoomListView extends StatefulWidget {
  const ChatRoomListView({super.key, this.onChatRoomTap});

  final Function(ChatRoomRow chatRoom)? onChatRoomTap;

  @override
  State<ChatRoomListView> createState() => _ChatRoomListViewState();
}

class _ChatRoomListViewState extends State<ChatRoomListView> {
  List<ChatRoomRow> _chatRooms = [];

  // on init must get chat rooms
  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    // Fetch chat rooms from the server or database
    final chatRooms = await ChatRoomService().getAllChatRooms();
    setState(() {
      _chatRooms = chatRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = _chatRooms[index];
        // TODO let's style this
        return ListTile(
          title: Text(chatRoom.name ?? ""),
          subtitle: Text(
            chatRoom.lastMessage ?? "",
          ),
          onTap: () {
            widget.onChatRoomTap?.call(chatRoom);
          },
        );
      },
    );
  }
}
