import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room_message.row.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatRoomMessageRow message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        // color: isSender ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        message.text ?? "No Text",
        style: TextStyle(
          // color: isSender ? Colors.black : Colors.black87,
        ),
      ),
    );
  }
}
