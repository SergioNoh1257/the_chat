import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/pages/account/account_data.dart';
import 'package:the_chat/pages/account/account_images.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late final AppData appData = context.watch<AppData>();
  final bool _editing = false;

  _updateFields() {
    GlobalSnackBar.show(
      "En construcción...",
      icon: Icons.construction,
      showCloseIcon: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appData.themeColor.shade500,
        iconTheme: IconThemeData(
          color: appData.determineColor(
            condition: "themeColor",
          ),
        ),
        title: Text(
          "Perfil",
          style: TextStyle(
            color: appData.determineColor(
              condition: "themeColor",
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _updateFields();
            },
            tooltip: _editing ? "Guardar cambios" : "Editar perfil",
            icon: Icon(
              _editing ? Icons.done : Icons.edit,
            ),
          ),
        ],
      ),
      body: ListView(
        children: const [
          AccountImages(),
          AccountData(),
        ],
      ),
    );
  }
}
