// ignore_for_file: avoid_web_libraries_in_flutter

import "dart:async";
import "dart:html" as html;

class CheckConnexion {
  //Maintain internal state
  bool _isOnline = true;

  final StreamController _onlineController = StreamController.broadcast();

  static final CheckConnexion _instance = CheckConnexion._internal();

  factory CheckConnexion() {
    // Get instance Web
    return _instance;
  }

  Stream get getConnection => _onlineController.stream;

  CheckConnexion._internal() {
    //Init
    _onlineController.add(true);

    //Then
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final bool onLine = html.window.navigator.onLine ?? true;

      if (onLine != _isOnline) {
        _isOnline = onLine;
        _onlineController.add(onLine);
      }
    });
  }
}
