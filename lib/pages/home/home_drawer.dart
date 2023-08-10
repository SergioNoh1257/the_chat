import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/router/app_router.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    return Drawer(
      elevation: 8.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: appData.themeColor),
            padding: const EdgeInsets.all(0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  appData.userProfilePhoto,
                  frameBuilder: (_, child, frame, __) {
                    return AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      foregroundDecoration: BoxDecoration(
                        color: frame != null
                            ? Colors.transparent
                            : appData.themeColor,
                      ),
                      child: child,
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: appData.determineTextColorOf(
                        appData.themeColor.shade500,
                        lightColor: Colors.white24,
                        darkColor: Colors.black26,
                      ),
                    ),
                  ),
                  filterQuality: FilterQuality.low,
                  fit: BoxFit.cover,
                ),
                Material(
                  color: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appData.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                appData.userEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: "Cerrar",
                              onPressed: () =>
                                  context.canPop() ? context.pop() : null,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              tooltip: "Ir a tu cuenta",
                              onPressed: () => context.goNamed(Routes.account),
                              icon: Icon(
                                Icons.adaptive.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () => context.goNamed(Routes.settings),
          ),
        ],
      ),
    );
  }
}
