import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/funcionalities/custom_window.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/router/app_router.dart';

import 'package:the_chat/connectivity/global.dart';
import 'package:the_chat/scaffold/app_bar.dart';

class Settings extends Connectivity {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConnectivityState<Settings> {
  late final AppData appData = context.watch<AppData>();
  Color _color = Colors.blue;

  @override
  void deactivate() {
    ScaffoldMessenger.maybeOf(context)?.clearMaterialBanners();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      switch (appData.themeMode) {
        case ThemeMode.light:
          return Icons.brightness_7;

        case ThemeMode.dark:
          return Icons.brightness_2;

        default:
          return Icons.brightness_auto;
      }
    }

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

    return Scaffold(
      appBar: CustomAppBar(
        title: "Configuración",
        backgroundColor: appData.themeColor.shade500,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: buildLeadingIcon(getIcon()),
            title: const Text("Alternar modo claro/oscuro/sistema"),
            onTap: () async {
              try {
                switch (appData.themeMode) {
                  case ThemeMode.light:
                    await appData.setType(ThemeMode.dark);
                    break;
                  case ThemeMode.dark:
                    await appData.setType(ThemeMode.system);
                    break;
                  case ThemeMode.system:
                    await appData.setType(ThemeMode.light);
                    break;
                }
              } catch (_) {
                GlobalSnackBar.show(
                  "Ha ocurrido un error. Comprueba tu conexión a internet",
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
          ListTile(
            leading: buildLeadingIcon(Icons.colorize),
            title: const Text("Color de aplicación"),
            subtitle: const Text("Esto se aplicará de forma global"),
            onTap: () => CustomWindow().showWindow(
              context,
              Column(
                children: [
                  MaterialPicker(
                    pickerColor: _color,
                    onColorChanged: (newColor) {
                      setState(() {
                        _color = newColor;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await appData.setColor(_color.value);
                      } catch (_) {
                        GlobalSnackBar.show(
                          "Ha ocurrido un error. Comprueba tu conexión a internet",
                          backgroundColor: Colors.red,
                        );
                      } finally {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Cambiar color"),
                  ),
                ],
              ),
              title: "Color de aplicación",
            ),
          ),
          ListTile(
            leading: buildLeadingIcon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () => context.goNamed(
              Routes.preSignOut,
              extra: 1,
            ),
          ),
        ],
      ),
    );
  }
}
