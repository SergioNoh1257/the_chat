import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/pages/home/status_view/status_view.dart';
import 'package:the_chat/router/app_router.dart';

mixin StatusGeneratorMixin on State<StatusView> {
  List<ListTile> createStatuses(List<dynamic>? data) {
    List<ListTile> statuses = [];
    final String userId = context.read<AppData>().userId;

    if (userId.isEmpty) return [];

    if (data == null || data.isEmpty) return [];

    for (var status in data) {
      //Check id
      if (status["id"] == null) continue;

      //Check id
      if (status["message"] == null || status["message"].isEmpty) continue;

      final DateTime? time = DateTime.tryParse(status["timestamp"] ?? "");

      final String? convertedTime =
          time != null ? DateFormat("HH:mm").format(time) : null;

      statuses.add(
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
              (status["sender_data"]["profile_photo"]) ?? "",
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
            "${status['sender_data']['name']}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${status['message']}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(convertedTime ?? ""),
          onTap: () => context.goNamed(
            Routes.status,
            extra: status,
          ),
        ),
      );
    }

    return statuses;
  }
}
