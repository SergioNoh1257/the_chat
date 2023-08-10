// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/pages/home/chats_view/chat_view.dart';
import 'package:the_chat/router/app_router.dart';

mixin ChatGeneratorMixin on State<ChatView> {
  List<ListTile> createChats(List<dynamic>? data) {
    List<ListTile> chats = [];
    final String userId = context.read<AppData>().userId;

    //Check if user is logged
    if (userId.isEmpty) return [];

    if (data == null || data.isEmpty) return [];

    data.sort(
      (a, b) {
        final List<dynamic> aMsg = a["messages"];
        final List<dynamic> bMsg = b["messages"];

        DateTime aDate = (aMsg.isNotEmpty)
            ? DateTime.tryParse(aMsg[0]["timestamp"]) ?? DateTime(0)
            : DateTime(0);

        DateTime bDate = (bMsg.isNotEmpty)
            ? DateTime.tryParse(bMsg[0]["timestamp"]) ?? DateTime(0)
            : DateTime(0);

        final int aTimestamp = aDate.millisecondsSinceEpoch;
        final int bTimestamp = bDate.millisecondsSinceEpoch;

        return bTimestamp.compareTo(aTimestamp);
      },
    );

    for (var conversation in data) {
      //Check id
      if (conversation["id"] == null) continue;

      //Check user ids
      if (conversation["user1_id"] == null || conversation["user1_id"].isEmpty)
        continue;

      if (conversation["user2_id"] == null || conversation["user2_id"].isEmpty)
        continue;

      //Check user data
      if (conversation["user1"] == null || conversation["user1"].isEmpty)
        continue;

      if (conversation["user2"] == null || conversation["user2"].isEmpty)
        continue;

      if (conversation["messages"] == null || conversation["messages"].isEmpty)
        continue;

      final String idUser1 = conversation["user1_id"];
      final String idUser2 = conversation["user2_id"];

      final Map<String, dynamic> user1 = conversation["user1"];
      final Map<String, dynamic> user2 = conversation["user2"];

      final List<dynamic> currentMessageArray = conversation["messages"];

      final Map<dynamic, dynamic>? currentMessage =
          currentMessageArray.isNotEmpty ? currentMessageArray[0] : null;

      final DateTime? lastMessageTime =
          DateTime.tryParse(currentMessage?["timestamp"] ?? "");

      final String? convertedTime = lastMessageTime != null
          ? DateFormat("HH:mm").format(lastMessageTime)
          : null;

      chats.add(
        ListTile(
          leading: Container(
            height: 40,
            width: 40,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Image.network(
              (userId == idUser1
                      ? user2["profile_photo"]
                      : user1["profile_photo"]) ??
                  "",
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return GestureDetector(
                  onTap: () => GlobalNavigator.showDialogWithContent(
                      content: SizedBox.square(
                    dimension: 200,
                    child: child,
                  )),
                  child: child,
                );
              },
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: Colors.white,
              ),
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            userId == idUser1 ? user2["name"] : user1["name"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${currentMessage?['sender_id'] == userId ? 'Tú: ' : ''}${currentMessage?['message'] ?? ''}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(convertedTime ?? ""),
          onTap: () => context.goNamed(
            Routes.chat,
            extra: userId == idUser1 ? idUser2 : idUser1,
          ),
        ),
      );
    }

    return chats;
  }
}
