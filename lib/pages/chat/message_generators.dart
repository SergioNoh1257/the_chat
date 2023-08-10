import 'package:flutter/material.dart';
import 'package:the_chat/pages/chat/chat.dart';
import 'package:the_chat/pages/chat/message.dart';

mixin MessageGeneratorMixin on State<Chat> {
  Future<List<Message>> convertMessages(
      List<dynamic> data, String chatId) async {
    List<Message> messages = [];

    if (data.isEmpty) return <Message>[];

    for (Map<String, dynamic> messageData in data) {
      if (messageData["chat_id"] != chatId) continue;

      if (messageData["sender_id"] == null ||
          messageData["sender_id"].isEmpty) {
        continue;
      }

      if ((messageData["message"] == null || messageData["message"].isEmpty) &&
          (messageData["attach"] == null || messageData["attach"].isEmpty)) {
        continue;
      }

      messages.add(
        Message(
          message: messageData['message'],
          senderId: messageData['sender_id'],
          timestamp: messageData['timestamp'],
          attach: messageData['attach'],
        ),
      );
    }

    return messages;
  }
}
