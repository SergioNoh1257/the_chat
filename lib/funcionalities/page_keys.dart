import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageKeys extends StatefulWidget {
  final FocusNode focusNode;
  final List<String> keys;
  final List<void Function()> actions;
  final Widget child;
  final bool Function() ignoreIf;

  const PageKeys({
    super.key,
    required this.keys,
    required this.actions,
    required this.child,
    required this.focusNode,
    required this.ignoreIf,
  })  : assert(keys.length > 0 && actions.length > 0),
        assert(actions.length == keys.length);

  @override
  State<PageKeys> createState() => _PageKeysState();
}

class _PageKeysState extends State<PageKeys> {
  String? lastKey;

  @override
  void initState() {
    super.initState();

    if (widget.actions.isEmpty || widget.keys.isEmpty) {
      throw Exception(
        "Algún campo está vacío. Intente añadir datos",
      );
    }
    if (widget.actions.length != widget.keys.length) {
      throw Exception(
        "Algún campo tiene una cantidad distinta de la otra. Intente añadir los datos correctamente",
      );
    }

    widget.focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: (RawKeyEvent key) {
        if (!widget.ignoreIf()) {
          if (key is RawKeyDownEvent) {
            setState(() {
              lastKey = key.character;
            });
          }

          if (key is RawKeyUpEvent) {
            for (var i = 0; i < widget.keys.length; i++) {
              if (lastKey?.toLowerCase() == widget.keys[i]) {
                widget.actions[i]();
              }
            }
          }
        }
      },
      focusNode: widget.focusNode,
      child: widget.child,
    );
  }
}
