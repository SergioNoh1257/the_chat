import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/enums/data_state.dart';
import 'package:the_chat/keys.dart';
// import 'package:the_chat/pages/chat/attach_manager.dart';
import 'package:the_chat/pages/chat/message.dart';
import 'package:the_chat/pages/chat/message_generators.dart';
import 'package:the_chat/state_info/error_info.dart';
import 'package:the_chat/state_info/loading_info.dart';
import 'package:the_chat/state_info/no_info.dart';
import 'package:uuid/uuid.dart';

class Chat extends StatefulWidget {
  final String id;
  const Chat({super.key, required this.id});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with MessageGeneratorMixin {
  final _client = Supabase.instance.client;
  // final AttachManager _attachManager = AttachManager();

  late final AppData appData = context.watch<AppData>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  StreamSubscription? _chatSubscription;

  List<Message> _chatData = [];

  DataState _currentState = DataState.idle;

  late String chatId;

  @override
  void initState() {
    chatId = const Uuid().v4();

    _init();

    super.initState();
  }

  @override
  dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _verifyChat() async {
    final userId = context.read<AppData>().userId;
    try {
      if (userId.isEmpty) throw Exception("No user found!");

      final List<List<String>> conditions = [
        [userId, widget.id],
        [widget.id, userId],
      ];

      for (final condition in conditions) {
        final List<dynamic> response = await _client
            .from("conversations")
            .select('*')
            .eq("user1_id", condition[0])
            .eq("user2_id", condition[1])
            .order("timestamp", ascending: false)
            .limit(1);

        if (response.isNotEmpty) {
          if (mounted) setState(() => chatId = response[0]["id"]);
          return true;
        }
      }
      return false;
    } catch (_) {
      _updateState(DataState.error);
      return false;
    }
  }

  _init() async {
    final bool exists = await _verifyChat();

    if (!exists) {
      _updateState(DataState.success);
    } else {
      _fetchMessages();
    }
  }

  _updateState(DataState newState) {
    if (mounted) setState(() => _currentState = newState);
  }

  _updateData(List<dynamic> data) async {
    try {
      List<Message> convertedMessages = await convertMessages(data, chatId);
      if (mounted) setState(() => _chatData = convertedMessages);
    } catch (_) {
      //
    }
  }

  Future<void> _fetchMessages() async {
    if (_chatSubscription != null) {
      await _chatSubscription?.cancel();
    }

    _chatSubscription = _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order("timestamp", ascending: false)
        .listen((messages) {
          _updateData(messages);
          _updateState(DataState.success);
        }, onError: (_, __) {
          _updateState(DataState.error);
        }, onDone: () {
          _updateState(DataState.done);
        });
  }

  Future<bool> _createChat() async {
    final userId = context.read<AppData>().userId;
    try {
      final response = await _client.from('conversations').insert(
        {
          'id': chatId,
          'user1_id': userId,
          'user2_id': widget.id,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ).select();

      return response != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendMessage() async {
    final userId = context.read<AppData>().userId;
    final message = _controller.text.trim();
    final bool exists = await _verifyChat();

    if (!exists) {
      final chatCreated = await _createChat();
      if (!chatCreated) {
        GlobalSnackBar.show(
            "Ocurrió un error al crear el chat y el mensaje no se pudo enviar, intente más tarde");
        return;
      }
      _fetchMessages();
    }

    if (message.isNotEmpty) {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': userId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  _buildChat() {
    switch (_currentState) {
      case DataState.none:
      case DataState.error:
        return const ErrorInfo();
      case DataState.idle:
        return const LoadingInfo();
      case DataState.done:
      case DataState.success:
        if (_chatData.isEmpty) return const NoInfo();
        return ListView.builder(
          reverse: true,
          itemCount: _chatData.length,
          padding: const EdgeInsets.all(2.5),
          itemBuilder: (context, index) => _chatData[index],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: appData.themeColor.shade500.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
        ),
        title: Text(
          "Conversación",
          style: TextStyle(
            color: appData.themeColor.shade500.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
          ),
        ),
        backgroundColor: appData.themeColor.shade500,
      ),
      body: _buildChat(),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        child: TextField(
            focusNode: _focus,
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Escribe un mensaje",
              suffixIcon: IconButton(
                onPressed: () async {
                  // var files = await _attachManager.selectFiles();
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _verifyChat();
              _sendMessage();
              _controller.clear();
              _focus.requestFocus();
            }),
      ),
    );
  }
}
