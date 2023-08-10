import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppData with ChangeNotifier {
  bool isOnline = false;
  final _auth = Supabase.instance.client.auth;
  Map<String, dynamic>? _userMetadata;
  String? _name;
  String? _id;

  AppData() {
    _userMetadata = _auth.currentUser?.userMetadata;
    _initTrack();
  }

  _initTrack() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      _userMetadata = event.session?.user.userMetadata;
      _name = event.session?.user.email;
      _id = event.session?.user.id;

      notifyListeners();
    });
  }

  MaterialColor get themeColor =>
      _getMaterialColorFrom(Color(_userMetadata?["theme_color"] ?? 0xFFE91E63));

  String get selectedLang => _userMetadata?["selected_lang"] ?? "es";

  int get lastModification => _userMetadata?["last_modification"] ?? 0;

  String get userName => _userMetadata?["name"] ?? "";

  String get userEmail => _name ?? "";

  String get userId => _id ?? "";

  String get userInfo => _userMetadata?["info"] ?? "¡Hola! Estoy en Chat!";

  String get userProfilePhoto => _userMetadata?["profile_photo"] ?? "";

  String get userCoverPhoto => _userMetadata?["cover_photo"] ?? "";

  List<dynamic> get contacts => _userMetadata?["contacts_list"] ?? [];

  ThemeMode get themeMode {
    final String mode = _userMetadata?["theme_mode"] ?? "light";

    switch (mode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setType(ThemeMode mode) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    String? parsedMode;

    switch (mode) {
      case ThemeMode.light:
        parsedMode = "light";
        break;
      case ThemeMode.dark:
        parsedMode = "dark";
        break;
      case ThemeMode.system:
        parsedMode = "system";
        break;
    }

    final UserResponse response = await _auth.updateUser(
      UserAttributes(
        data: {
          "last_user_modification": timestamp,
          "theme_mode": parsedMode,
        },
      ),
    );

    _userMetadata = response.user?.userMetadata;
    notifyListeners();
  }

  Future<void> setColor(int color) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final UserResponse response = await _auth.updateUser(
      UserAttributes(
        data: {
          "last_user_modification": timestamp,
          "theme_color": color,
        },
      ),
    );

    _userMetadata = response.user?.userMetadata;

    notifyListeners();
  }

  MaterialColor _getMaterialColorFrom(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  bool get isChatStyleExperimental => true;

  bool get isDesktop {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      default:
        return false;
    }
  }

  determineColor({
    Color lightColor = Colors.white,
    Color darkColor = Colors.black,
    Color background = Colors.black54,
    String condition = "default",
  }) {
    switch (condition.trim().toLowerCase()) {
      case "themecolor":
        return themeColor.shade500.computeLuminance() < 0.5
            ? lightColor
            : darkColor;
      case "theme":
      case "themedarkinverse":
        return (themeMode == ThemeMode.light || themeMode == ThemeMode.system)
            ? darkColor
            : lightColor;
      case "themeinverse":
      case "themedark":
        return (themeMode == ThemeMode.dark || themeMode == ThemeMode.system)
            ? darkColor
            : lightColor;
      case "auto":
        return themeMode == ThemeMode.system ? darkColor : lightColor;
      case "autoinverse":
        return themeMode != ThemeMode.system ? darkColor : lightColor;
      case "custom":
        return background.computeLuminance() < 0.5 ? lightColor : darkColor;
      case "custominverse":
        return background.computeLuminance() > 0.5 ? lightColor : darkColor;
      case "default":
        return Colors.black;
      default:
        throw Exception('''Cannot determine "$condition".
          Allowed values are:
              * themeColor
              * theme or themeInverse
              * themeDark or themeDarkInverse
              * auto or autoInverse
              * custom or customInverse
              * default''');
    }
  }

  Color determineTextColorOf(Color secondColor,
      {Color lightColor = Colors.white, Color darkColor = Colors.black}) {
    return secondColor.computeLuminance() > 0.5 ? darkColor : lightColor;
  }
}
