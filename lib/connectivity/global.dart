import 'dart:async';

import 'package:flutter/material.dart';

import 'package:the_chat/connectivity/native.dart'
    if (dart.library.html) 'package:the_chat/connectivity/web.dart';
import 'package:the_chat/keys.dart';

class Connectivity extends StatefulWidget {
  const Connectivity({super.key});

  @override
  State<Connectivity> createState() => ConnectivityState();
}

class ConnectivityState<T extends StatefulWidget> extends State<T> {
  //Connection Singlenton
  final _conn = CheckConnexion();

  //Subscription
  StreamSubscription? _connSubscription;

  //Check
  bool _isOnline = true;

  @override
  void initState() {
    _connSubscription = _conn.getConnection.listen((event) {
      if (event != _isOnline) {
        setState(() {
          _isOnline = event;
          _setStatus();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _connSubscription?.cancel();
    super.dispose();
  }

  _setStatus() {
    GlobalSnackBar.show(
      _isOnline
          ? "Se ha restablecido la conexión"
          : "Comprueba tu conexión a internet",
      icon: _isOnline ? Icons.wifi : Icons.cloud_off,
      backgroundColor: _isOnline ? Colors.green : Colors.red,
    );

    /* sm?.hideCurrentSnackBar();

    sm?.showSnackBar(
      SnackBar(
        content: 
    );
   */
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
