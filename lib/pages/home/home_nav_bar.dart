import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class HomeNavigationBar extends StatelessWidget {
  final int index;
  final void Function(int) onChanged;
  final List<Map<String, dynamic>> items;
  const HomeNavigationBar(
      {super.key,
      required this.index,
      required this.onChanged,
      required this.items});

  @override
  Widget build(BuildContext context) {
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    final appData = context.watch<AppData>();

    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      indicatorColor: appData.themeColor.shade500,
      selectedIndex: index,
      onDestinationSelected: (newIndex) => onChanged(newIndex),
      backgroundColor: Color.lerp(
        scaffoldBackground,
        appData.themeColor,
        0.05,
      ),
      shadowColor: appData.themeColor,
      destinations: items.map((e) {
        return NavigationDestination(
          icon: Icon(e["icon"]),
          selectedIcon: Icon(
            e["icon"],
            color: appData.determineTextColorOf(
              appData.themeColor,
            ),
          ),
          label: e["label"],
        );
      }).toList(),
    );
  }
}
