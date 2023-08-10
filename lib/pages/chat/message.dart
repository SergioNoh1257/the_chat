import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';

class Message extends StatefulWidget {
  final String? message;
  final String senderId;
  final String timestamp;
  final List<String>? attach;

  const Message(
      {super.key,
      this.message,
      required this.senderId,
      required this.timestamp,
      this.attach});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  late final userData = context.read<AppData>();
  late final userId = userData.userId;
  late final userColor = userData.themeColor;
  final _client = Supabase.instance.client;

  _getTime() {
    return DateFormat("HH:mm")
        .format(DateTime.tryParse(widget.timestamp) ?? DateTime(0));
  }

  _showOptions() {
    GlobalNavigator.showDialogWithContent(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Visibility(
              visible: widget.senderId == userId,
              child: ListTile(
                title: const Text("Borrar Mensaje"),
                onTap: () => _delete(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _delete() async {
    try {
      if (context.canPop()) context.pop();

      await _client.from("messages").delete().match({
        "message": widget.message,
        "sender_id": widget.senderId,
        "timestamp": widget.timestamp,
      });
    } catch (_) {
      GlobalSnackBar.show(
        "No se pudo borrar el mensaje",
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      child: Align(
        alignment: widget.senderId == userId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: min(size.width * 0.6, 400),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Material(
              color: widget.senderId == userId ? userColor : userColor.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.senderId == userId ? 7.5 : 0),
                topRight: Radius.circular(widget.senderId == userId ? 0 : 7.5),
                bottomLeft: const Radius.circular(7.5),
                bottomRight: const Radius.circular(7.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.senderId == userId
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message ?? "",
                      softWrap: true,
                      textAlign: widget.senderId == userId
                          ? TextAlign.end
                          : TextAlign.start,
                      style: TextStyle(
                        color: userColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      _getTime(),
                      style: TextStyle(
                        fontSize: 10,
                        color: userColor.computeLuminance() > 0.5
                            ? Colors.black45
                            : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: () => _showOptions(),
    );
  }
}
