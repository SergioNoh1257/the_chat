import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class CheckConnexion {
  final Connectivity conn = Connectivity();

  static final CheckConnexion _instance = CheckConnexion._internal();

  final StreamController _onlineController = StreamController.broadcast();

  factory CheckConnexion() {
    //Get instance Native
    return _instance;
  }

  Stream get getConnection => _onlineController.stream;

  CheckConnexion._internal() {
    //Init
    _onlineController.add(true);

    //Then
    conn.onConnectivityChanged.listen((event) {
      _onlineController.add(event != ConnectivityResult.none);
    });
  }
}
