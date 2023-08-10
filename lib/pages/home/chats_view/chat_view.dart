import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/pages/home/chats_view/chat_generators.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with ChatGeneratorMixin, AutomaticKeepAliveClientMixin {
  final _client = Supabase.instance.client;

  late Timer timer;

  bool _isUpdating = false;
  bool _isError = false;

  List<ListTile> _data = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  _init() async {
    //Fetch first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLastMessage();
    });

    //Repeat every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _getLastMessage();
    });
  }

  _getLastMessage() async {
    try {
      final id = context.read<AppData>().userId;

      if (mounted) setState(() => _isUpdating = true);

      final response = await _client
          .from("conversations")
          .select(
              'id, messages(message, sender_id, timestamp), user1_id, user2_id, user1:user1_id(name, profile_photo), user2:user2_id(name, profile_photo)')
          .or("user1_id.eq.$id,user2_id.eq.$id")
          .limit(1, foreignTable: "messages")
          .limit(30)
          .order("timestamp", foreignTable: "messages")
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception("Time limit reached for search contacts");
        },
      );

      if (mounted) {
        final chats = createChats(response);
        setState(() {
          _data = chats;
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isError = true);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: _isUpdating
                ? const CircularProgressIndicator()
                : SizedBox.square(
                    dimension: 40,
                    child: Icon(_isError ? Icons.close : Icons.done)),
            title: Text(
              _isUpdating ? "Actualizando" : "Última actualización",
            ),
            subtitle: Text(
              _isUpdating
                  ? "Espere por favor..."
                  : DateFormat("HH:mm:ss").format(DateTime.now()),
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            shrinkWrap: true,
            itemCount: _data.length,
            itemBuilder: (context, index) {
              return _data[index];
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
