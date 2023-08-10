import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class AccountData extends StatelessWidget {
  const AccountData({super.key});

  @override
  Widget build(BuildContext context) {
    final AppData appData = context.watch<AppData>();

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
      physics: const NeverScrollableScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      shrinkWrap: true,
      children: [
        ListTile(
          leading: buildLeadingIcon(Icons.person),
          title: const Text("Nombre"),
          subtitle: Text(appData.userName),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.email),
          title: const Text("Correo"),
          subtitle: Text(appData.userEmail),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.info),
          title: const Text("Información"),
          subtitle: Text(appData.userInfo),
        ),
        ListTile(
          leading: buildLeadingIcon(Icons.update),
          title: const Text("Ultima modificación al perfil"),
          //Format the last update of user
          subtitle: Text(
              "${DateTime.fromMillisecondsSinceEpoch(appData.lastModification).toUtc()}"),
        ),
      ],
    );
  }
}
