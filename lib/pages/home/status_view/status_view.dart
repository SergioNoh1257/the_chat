import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/pages/home/status_view/status_generators.dart';
import 'package:the_chat/router/app_router.dart';

class StatusView extends StatefulWidget {
  const StatusView({super.key});

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView>
    with StatusGeneratorMixin, AutomaticKeepAliveClientMixin {
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
    super.dispose();
  }

  _init() async {
    //Fetch first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLastStatuses();
    });

    //Repeat every 30 seconds
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _getLastStatuses();
    });
  }

  _getLastStatuses() async {
    try {
      final user = context.read<AppData>();
      final userId = user.userId;
      final contacts = user.contacts;

      if (mounted) setState(() => _isUpdating = true);

      final response = await _client
          .from("status")
          .select("*, sender_data:sender_id(name, profile_photo)")
          .neq(
            "sender_id",
            userId,
          )
          .in_("sender_id", contacts)
          .gt(
            "timestamp",
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          )
          .order("timestamp", ascending: false)
          .order("sender_data(name)", ascending: true)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception("Time Limit reached for search statuses");
        },
      );

      if (mounted) {
        final statuses = createStatuses(response);
        setState(() {
          _data = statuses;
          _isError = false;
        });
      }
    } catch (_) {
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
            leading: const SizedBox.square(
              dimension: 40,
              child: Icon(Icons.add),
            ),
            title: const Text("Subir un estado"),
            onTap: () => context.goNamed(Routes.newStatus),
          ),
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
