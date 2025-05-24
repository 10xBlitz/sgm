import 'package:flutter/material.dart';
import 'package:sgm/mainTabs/chat/widgets/chat_bubble.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room_message.row.dart';
import 'package:sgm/services/chat_room_messages.service.dart';

class ChatRoomMessagesListView extends StatelessWidget {
  const ChatRoomMessagesListView({
    super.key,
    required this.chatRoomId,
    this.scrollController,
  });

  final String chatRoomId;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoomMessageRow>>(
      stream: ChatRoomMessagesService().streamChatRoomMessages(chatRoomId),
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Get messages or empty list if null
        final messages = snapshot.data ?? [];

        // Handle empty state
        if (messages.isEmpty) {
          return const Center(
            child: Text('No messages yet'),
          );
        }

        // Build message list
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - index - 1];
            return ChatBubble(message: message);
          },
        );
      },
    );
  }
}
