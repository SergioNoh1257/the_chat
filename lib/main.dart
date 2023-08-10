import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/router/app_router.dart';
import 'package:the_chat/keys.dart';

import 'package:the_chat/private/supabase.dart';

import 'package:the_chat/url_strategy/native.dart'
    if (dart.library.html) 'package:the_chat/url_strategy/web.dart';

void main() async {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await sp.Supabase.initialize(
    url: SUPA_URL,
    anonKey: SUPA_ANON_KEY,
    debug: false,
  );

  runApp(const Start());
}

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(create: (_) => AppData()),
      ],
      child: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with RouterMixin {
  late final AppData appData = context.watch<AppData>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Chat!",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: appData.themeColor,
        colorSchemeSeed: appData.themeColor,
        brightness: Brightness.light,
        visualDensity: VisualDensity.comfortable,
        useMaterial3: true,
        fontFamily: "Questrial",
      ),
      darkTheme: ThemeData(
        // primarySwatch: appData.themeColor,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.comfortable,
        useMaterial3: true,
        fontFamily: "Questrial",
      ),
      scaffoldMessengerKey: smKey,
      themeMode: appData.themeMode,
      routerConfig: router,
    );
  }
}
