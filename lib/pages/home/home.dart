import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/connectivity/global.dart';
import 'package:the_chat/pages/home/chats_view/chat_view.dart';
import 'package:the_chat/pages/home/home_drawer.dart';
import 'package:the_chat/pages/home/home_nav_bar.dart';
import 'package:the_chat/pages/home/home_nav_rail.dart';
import 'package:the_chat/pages/home/search_view/search.dart';
import 'package:the_chat/pages/home/status_view/status_view.dart';
import 'package:the_chat/scaffold/app_bar.dart';

class Home extends Connectivity {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends ConnectivityState<Home> {
  final PageController _controller = PageController(
    initialPage: 0,
  );

  late final AppData appData = context.watch<AppData>();

  int _index = 0;

  final List<Widget> _pages = const [
    ChatView(),
    StatusView(),
    Center(
      child: Text("Proximamente"),
    ),
    Search(),
  ];

  final List<Map<String, dynamic>> _items = [
    {
      "icon": Icons.chat_bubble,
      "label": "Chats",
    },
    {
      "icon": Icons.nature_people,
      "label": "Estados",
    },
    {
      "icon": Icons.person,
      "label": "Contactos",
    },
    {
      "icon": Icons.search,
      "label": "Buscar",
    },
  ];

  _setPage(int page, {bool update = false}) async {
    if (page != _index) {
      try {
        if (!update) {
          await _controller.animateToPage(
            page,
            duration: Duration(milliseconds: (page - _index).abs() * 150),
            curve: Curves.easeInOut,
          );
        }
      } finally {
        setState(() => _index = page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: size.width < 600 ? const HomeDrawer() : null,
      appBar: CustomAppBar(
        title: "Chat!",
        backgroundColor: appData.themeColor,
      ),
      body: Row(
        children: [
          size.width > 600
              ? HomeNavigationRail(
                  index: _index,
                  items: _items,
                  onChanged: (index) => _setPage(index),
                  extended: size.width > 840,
                )
              : const SizedBox.shrink(),
          Flexible(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              child: PageView.builder(
                allowImplicitScrolling: true,
                onPageChanged: (index) => _setPage(index, update: true),
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: size.width < 600
          ? HomeNavigationBar(
              index: _index,
              items: _items,
              onChanged: (index) => _setPage(index),
            )
          : null,
    );
  }
}
