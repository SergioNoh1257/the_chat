import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';

class ProfileData extends StatefulWidget {
  final String id;
  final String? name;
  final String? email;
  final String? info;

  const ProfileData({
    super.key,
    this.name,
    this.email,
    this.info,
    required this.id,
  });

  @override
  State<ProfileData> createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  final _client = Supabase.instance.client;
  late final AppData appData = context.watch<AppData>();

  bool _isContact() {
    final List<dynamic> contactsList =
        _client.auth.currentUser?.userMetadata?["contacts_list"] ?? [];

    bool isContact = false;

    for (var element in contactsList) {
      if (element == widget.id) {
        isContact = true;
      }
    }

    return isContact;
  }

  @override
  Widget build(BuildContext context) {
    SizedBox buildLeadingIcon(IconData icon) {
      return SizedBox(
        height: 30,
        width: 30,
        child: Center(
          child: Icon(
            icon,
            color: appData.themeColor.shade500,
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          leading: buildLeadingIcon(Icons.person),
          title: const Text("Estado"),
          subtitle: Text("${_isContact() ? "E" : "No e"}s un contacto"),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.person),
          title: const Text("Nombre"),
          subtitle: Text("${widget.name}"),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.email),
          title: const Text("Correo"),
          subtitle: Text("${widget.email}"),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.info),
          title: const Text("Información"),
          subtitle: Text(widget.info ?? "¡Hola!"),
        ),
      ],
    );
  }
}
