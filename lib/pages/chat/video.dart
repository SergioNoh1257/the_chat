// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CustomVideo extends StatefulWidget {
  final String url;
  const CustomVideo({super.key, required this.url});

  @override
  State<CustomVideo> createState() => _CustomVideoState();
}

class _CustomVideoState extends State<CustomVideo> {
  final GlobalKey _videoContainerKey = GlobalKey();
  final FocusNode _videoFocus = FocusNode();
  late VideoController _controller;

  bool _active = false;
  bool _changingVolume = false;
  int _pos = 0;
  double _volume = 100.0;

  Timer? _timerToHide;
  late Timer _timerToRefresh;

  final Player _player = Player();

  @override
  void initState() {
    _controller = VideoController(_player);

    _player.open(Media(widget.url), play: false);

    _timerToRefresh =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          if (_player.state.playing)
            _pos = _player.state.position.inMilliseconds;
          if (!_changingVolume) _volume = _player.state.volume;
        });
      }
    });

    _videoFocus.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _timerToHide?.cancel();
    _timerToRefresh.cancel();

    _player.dispose();

    super.dispose();
  }

  String _getPosition() {
    String pos = Duration(milliseconds: _pos).toString();
    return pos.substring(0, pos.length - 7);
  }

  void _activeScreen() {
    setState(() => _active = true);

    if (_timerToHide != null) _timerToHide?.cancel();

    _timerToHide = Timer(const Duration(seconds: 5), () {
      _inactiveScreen();
    });
  }

  void _inactiveScreen() {
    if (_timerToHide != null) _timerToHide?.cancel();

    setState(() => _active = false);
  }

  void _seek5Less() {
    _player.seek(
      Duration(
          milliseconds: max(
        0,
        _player.state.position.inMilliseconds - 5000,
      )),
    );
  }

  void _seek5More() {
    _player.seek(
      Duration(
          milliseconds: min(
        _player.state.duration.inMilliseconds,
        _player.state.position.inMilliseconds + 5000,
      )),
    );
  }

  Text _getText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: 4.0,
            ),
          ],
        ),
      );

  Icon _getIcon(IconData icon) => Icon(
        icon,
        color: Colors.white,
        shadows: const [
          Shadow(
            color: Colors.white54,
            blurRadius: 4.0,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _videoFocus,
      onKeyEvent: (KeyEvent key) {
        final LogicalKeyboardKey keyPressed = key.logicalKey;

        if (key is KeyUpEvent) {
          // Space
          if (keyPressed == LogicalKeyboardKey.space) _player.playOrPause();
          // <
          if (keyPressed == LogicalKeyboardKey.arrowLeft) _seek5Less();
          // >
          if (keyPressed == LogicalKeyboardKey.arrowRight) _seek5More();
          // M
          if (keyPressed == LogicalKeyboardKey.keyM)
            _player.setVolume(_player.state.volume > 0.0 ? 0.0 : 100.0);
        }
        if (key is KeyDownEvent || key is KeyRepeatEvent) {
          // ^
          if (keyPressed == LogicalKeyboardKey.arrowUp)
            _player.setVolume(min(_player.state.volume + 5.0, 100.0));
          // v
          if (keyPressed == LogicalKeyboardKey.arrowDown)
            _player.setVolume(max(_player.state.volume - 5.0, 0.0));
        }

        _activeScreen();
        _videoFocus.requestFocus();
      },
      child: MouseRegion(
        onExit: (_) => _inactiveScreen(),
        onHover: (_) => _activeScreen(),
        child: GestureDetector(
          key: _videoContainerKey,
          onTap: () {
            _active ? _inactiveScreen() : _activeScreen();
          },
          onDoubleTapDown: (details) {
            final double pointerWidth = details.localPosition.dx;
            final double containerWidth =
                _videoContainerKey.currentContext?.size?.width ?? 0;

            _activeScreen();

            pointerWidth > (containerWidth / 2) ? _seek5More() : _seek5Less();
          },
          child: AspectRatio(
            aspectRatio:
                (_player.state.width ?? 1) / (_player.state.height ?? 1),
            child: Stack(
              children: [
                Video(
                  controller: _controller,
                  controls: NoVideoControls,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(20),
                  color: _active ? Colors.black26 : Colors.transparent,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedCrossFade(
                      firstChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getIcon(Icons.volume_up),
                              Expanded(
                                child: Slider(
                                  value: _volume,
                                  min: 0.0,
                                  max: 100.0,
                                  onChanged: (volume) {
                                    setState(() => _volume = volume);
                                    _activeScreen();
                                  },
                                  onChangeStart: (_) =>
                                      setState(() => _changingVolume = true),
                                  onChangeEnd: (_) {
                                    _player.setVolume(_volume);
                                    setState(() => _changingVolume = false);
                                  },
                                ),
                              ),
                              _getText("${_volume.toInt()}%"),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getIcon(Icons.timer),
                              Expanded(
                                child: Slider(
                                  value: min(
                                    _pos.toDouble(),
                                    _player.state.duration.inMilliseconds
                                        .toDouble(),
                                  ),
                                  min: 0.0,
                                  max: _player.state.duration.inMilliseconds
                                      .toDouble(),
                                  onChanged: (pos) {
                                    setState(() => _pos = pos.toInt());
                                    _activeScreen();
                                  },
                                  onChangeStart: (_) => _player.pause(),
                                  onChangeEnd: (_) {
                                    _player.seek(Duration(milliseconds: _pos));
                                    _player.play();
                                  },
                                ),
                              ),
                              _getText(_getPosition()),
                            ],
                          ),
                        ],
                      ),
                      secondChild: const SizedBox(
                        height: 96,
                        width: double.infinity,
                      ),
                      crossFadeState: _active
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.center,
                      sizeCurve: Curves.easeInOut,
                    ),
                  ),
                ),
                Center(
                  child: AnimatedCrossFade(
                    firstChild: IconButton(
                      iconSize: 60,
                      icon: _getIcon(_player.state.completed
                          ? Icons.repeat
                          : _player.state.playing
                              ? Icons.play_arrow
                              : Icons.pause),
                      onPressed: () => _player.playOrPause(),
                    ),
                    secondChild: const SizedBox.square(dimension: 76),
                    crossFadeState: _active
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.center,
                    sizeCurve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
