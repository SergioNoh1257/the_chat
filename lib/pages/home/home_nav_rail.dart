import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/router/app_router.dart';

class HomeNavigationRail extends StatelessWidget {
  final bool extended;
  final int index;
  final void Function(int) onChanged;
  final List<Map<String, dynamic>> items;
  const HomeNavigationRail(
      {super.key,
      required this.index,
      required this.onChanged,
      required this.extended,
      required this.items});

  @override
  Widget build(BuildContext context) {
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    final appData = context.watch<AppData>();

    Color getUserColor() {
      return Color.lerp(
        scaffoldBackground,
        appData.themeColor.shade50,
        0.25,
      )!;
    }

    changeTheme() {
      appData.setType(
        appData.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
    }

    IconData getThemeIcon() {
      return appData.themeMode == ThemeMode.light
          ? Icons.brightness_7
          : Icons.brightness_2;
    }

    return NavigationRail(
      elevation: 16.0,
      useIndicator: true,
      backgroundColor: Color.lerp(
        scaffoldBackground,
        appData.themeColor,
        0.05,
      ),
      selectedIconTheme: IconThemeData(
        color: appData.determineTextColorOf(
          appData.themeColor,
        ),
      ),
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      extended: extended,
      minExtendedWidth: 200,
      indicatorColor: appData.themeColor,
      leading: Material(
        borderRadius: BorderRadius.circular(15),
        color: getUserColor(),
        elevation: 4.0,
        child: GestureDetector(
          onTap: () => context.goNamed(Routes.account),
          child: Tooltip(
            message: "${appData.userName}\n${appData.userEmail}",
            textAlign: TextAlign.center,
            child: Row(
              children: [
                Container(
                  height: 55,
                  width: 55,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    color: appData.themeColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: appData.themeColor,
                      width: 1.0,
                    ),
                  ),
                  child: Image.network(
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
                    errorBuilder: (_, __, ___) {
                      return Icon(
                        Icons.person,
                        color: appData.determineTextColorOf(
                          appData.themeColor,
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                Visibility(
                  visible: extended,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible: extended,
                  child: SizedBox(
                    width: 120,
                    child: Text(
                      appData.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: appData.determineTextColorOf(getUserColor()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      destinations: items.map((e) {
        return NavigationRailDestination(
          icon: Icon(e["icon"]),
          label: Text(e["label"]),
        );
      }).toList(),
      trailing: extended
          ? FloatingActionButton.extended(
              backgroundColor: appData.themeColor,
              foregroundColor: appData.determineTextColorOf(
                appData.themeColor,
              ),
              onPressed: () => changeTheme(),
              icon: Icon(getThemeIcon()),
              label: const Text("Cambiar de tema"),
            )
          : FloatingActionButton(
              backgroundColor: appData.themeColor,
              foregroundColor: appData.determineTextColorOf(
                appData.themeColor,
              ),
              onPressed: () => changeTheme(),
              child: Icon(getThemeIcon()),
            ),
      onDestinationSelected: (index) => onChanged(index),
      selectedIndex: index,
    );
  }
}
