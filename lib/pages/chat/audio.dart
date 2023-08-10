// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAudio extends StatefulWidget {
  final String url;
  const CustomAudio({
    super.key,
    required this.url,
  });

  @override
  State<CustomAudio> createState() => _CustomAudioState();
}

class _CustomAudioState extends State<CustomAudio> {
  final AudioPlayer _player = AudioPlayer();
  final FocusNode _focus = FocusNode();
  late StreamSubscription _playerState;
  late StreamSubscription _playerDuration;
  late StreamSubscription _playerPosition;

  Duration _position = Duration.zero;
  Duration _duration = const Duration(milliseconds: 1);

  double _volume = 100.0;

  @override
  void initState() {
    _player.setSourceUrl(widget.url);

    _playerState =
        _player.onPlayerStateChanged.listen((event) => setState(() {}));

    _playerPosition = _player.onPositionChanged
        .listen((position) => setState(() => _position = position));

    _playerDuration = _player.onDurationChanged
        .listen((duration) => setState(() => _duration = duration));

    _focus.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _playerState.cancel();

    _playerPosition.cancel();
    _playerDuration.cancel();

    _player.dispose();

    _focus.dispose();

    super.dispose();
  }

  String _parseUrl() => Uri.decodeFull(widget.url);

  String _getPosition() =>
      _position.toString().substring(0, _position.toString().length - 7);

  void _seek(int milliseconds) {
    _player.seek(
      Duration(
        milliseconds: milliseconds > 0
            ? max(
                0,
                _position.inMilliseconds + milliseconds,
              )
            : min(
                _duration.inMilliseconds,
                _position.inMilliseconds + milliseconds,
              ),
      ),
    );
  }

  void _pauseOrResume() {
    _player.state == PlayerState.playing ? _player.pause() : _player.resume();
  }

  void _muteOrUnmute() {
    _player.setVolume(_player.volume > 0.0 ? 0.0 : 1.0);
    setState(() => _volume = _player.volume * 100);
  }

  void _setVolume(double volume) {
    if (volume <= 0) _player.setVolume(0.0);
    if (volume >= 100) _player.setVolume(1.0);
    if (volume > 0 && volume < 100) _player.setVolume(volume / 100);
    setState(() {
      if (volume <= 0) _volume = 0;
      if (volume >= 100) _volume = 100;
      if (volume > 0 && volume < 100) _volume = volume;
    });
  }

  void _toogleRepeat() {
    _player.setReleaseMode(_player.releaseMode == ReleaseMode.loop
        ? ReleaseMode.stop
        : ReleaseMode.loop);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: KeyboardListener(
        focusNode: _focus,
        onKeyEvent: (KeyEvent key) {
          LogicalKeyboardKey keyPressed = key.logicalKey;
          if (key is KeyUpEvent) {
            // Space
            if (keyPressed == LogicalKeyboardKey.space) _pauseOrResume();
            // M
            if (keyPressed == LogicalKeyboardKey.keyM) _muteOrUnmute();
            // R
            if (keyPressed == LogicalKeyboardKey.keyR) _toogleRepeat();
          }
          if (key is KeyRepeatEvent || key is KeyDownEvent) {
            // >
            if (keyPressed == LogicalKeyboardKey.arrowLeft) _seek(-5000);
            // <
            if (keyPressed == LogicalKeyboardKey.arrowRight) _seek(5000);
            // ^
            if (keyPressed == LogicalKeyboardKey.arrowUp)
              _setVolume(_volume + 5);
            // v
            if (keyPressed == LogicalKeyboardKey.arrowDown)
              _setVolume(_volume - 5);
          }

          _focus.requestFocus();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _parseUrl().split(RegExp(r'/')).last,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: _duration.inMilliseconds.toDouble(),
                      value: min(
                        _position.inMilliseconds.toDouble(),
                        _duration.inMilliseconds.toDouble(),
                      ),
                      onChanged: (pos) => _player.seek(
                        Duration(
                            milliseconds:
                                min(pos.toInt(), _duration.inMilliseconds)),
                      ),
                    ),
                  ),
                  Text(_getPosition()),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 100.0,
                      value: _volume,
                      onChanged: (newVolume) {
                        _setVolume(newVolume);
                      },
                    ),
                  ),
                  Text("${_volume.toInt()}%"),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "-10",
                    onPressed: () => _seek(-10000),
                    icon: const Icon(
                      Icons.keyboard_double_arrow_left,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _pauseOrResume(),
                    tooltip: "Toggle play/pause",
                    icon: Icon(
                      _player.state == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _toogleRepeat(),
                    tooltip: "Toggle repeat",
                    icon: Icon(
                      _player.releaseMode == ReleaseMode.loop
                          ? Icons.repeat_on
                          : Icons.repeat,
                    ),
                  ),
                  IconButton(
                    tooltip: "+10",
                    onPressed: () => _seek(10000),
                    icon: const Icon(
                      Icons.keyboard_double_arrow_right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
