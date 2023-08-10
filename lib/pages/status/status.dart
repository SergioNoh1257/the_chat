import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class Status extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const Status({super.key, required this.data});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final FocusNode _focus = FocusNode();

  final Duration _timeToRefresh = const Duration(milliseconds: 50);

  final Duration _totalDuration = const Duration(seconds: 10);
  Duration _elapsedDuration = Duration.zero;

  bool _isPlaying = true;

  late Timer _refresh;

  @override
  void initState() {
    _refresh = Timer.periodic(_timeToRefresh, (_) {
      if (mounted && _isPlaying) {
        setState(() => _elapsedDuration += _timeToRefresh);
      }

      if (_elapsedDuration > _totalDuration) {
        context.canPop() ? context.pop() : null;
      }
    });

    _focus.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _refresh.cancel();

    super.dispose();
  }

  _pauseOrResume() {
    if (mounted) setState(() => _isPlaying = !_isPlaying);
    _focus.requestFocus();
  }

  Color _getColor() {
    return Color(widget.data["color"] as int? ?? 0xFF2196F3);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: appData.determineColor(
            background: _getColor(),
            condition: "custom",
          ),
        ),
        backgroundColor: _getColor(),
        title: Text(
          "Estado de ${widget.data["sender_data"]["name"]}",
          style: TextStyle(
            color: appData.determineColor(
              background: _getColor(),
              condition: "custom",
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.play_arrow : Icons.pause,
            ),
            tooltip: "Pause/Resume",
            onPressed: () => _pauseOrResume(),
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focus,
        onKeyEvent: (KeyEvent key) {
          final LogicalKeyboardKey keyPressed = key.logicalKey;
          if (key is KeyUpEvent) {
            if (keyPressed == LogicalKeyboardKey.space) _pauseOrResume();
          }
        },
        child: GestureDetector(
          onTap: () => _pauseOrResume(),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getColor(),
                      _getColor().withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "${widget.data["message"]}",
                      style: TextStyle(
                        fontSize: 35,
                        color: appData.determineColor(
                          background: _getColor(),
                          condition: "custom",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                width: min(
                    size.width,
                    ((_elapsedDuration.inMilliseconds /
                            _totalDuration.inMilliseconds) *
                        size.width)),
                height: 5.0,
                color: appData.determineColor(
                  background: _getColor(),
                  condition: "custom",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
