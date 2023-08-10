import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/scaffold/app_bar.dart';

class NewStatus extends StatefulWidget {
  const NewStatus({super.key});

  @override
  State<NewStatus> createState() => _NewStatusState();
}

class _NewStatusState extends State<NewStatus> {
  final _client = Supabase.instance.client;
  late final AppData appData = context.watch<AppData>();
  final TextEditingController _controller = TextEditingController();

  bool _isError = false;
  bool _isSending = false;

  Color _statusColor = Colors.blue;

  String? _getMessage() {
    final message = _controller.value.text.trim();

    if (message.isEmpty) {
      return null;
    }
    return message;
  }

  _setNewColor() {
    GlobalNavigator.showDialogWithContent(
      content: MaterialPicker(
        pickerColor: _statusColor,
        onColorChanged: (newColor) {
          setState(() {
            _statusColor = newColor;
          });
        },
      ),
    );
  }

  _send() async {
    try {
      final String? message = _getMessage();
      final String userId = context.read<AppData>().userId;

      if (mounted) {
        setState(() {
          _isSending = true;
          _isError = false;
        });
      }

      if (message == null || message.isEmpty) throw Exception("Mensaje vacío");

      if (userId.isEmpty) throw Exception("No se ha iniciado sesión");

      await _client.from("status").insert(
        {
          "timestamp": DateTime.now().toIso8601String(),
          "message": message,
          "sender_id": userId,
          "color": _statusColor.value,
        },
      );

      GlobalSnackBar.show(
        "Estado subido correctamente",
        backgroundColor: Colors.green,
        icon: Icons.done,
        showCloseIcon: true,
      );

      if (mounted) context.canPop() ? context.pop() : null;
    } catch (_) {
      if (mounted) setState(() => _isError = true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Nuevo Estado",
        actions: [
          IconButton(
            onPressed: () => _setNewColor(),
            tooltip: "Change Color",
            icon: const Icon(Icons.colorize),
          ),
        ],
        backgroundColor: _statusColor,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_statusColor, _statusColor.withOpacity(0.8)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(
              _getMessage() ?? "Escribe tu mensaje",
              style: TextStyle(
                fontSize: 35,
                color: appData.determineTextColorOf(
                  _statusColor,
                  lightColor:
                      _getMessage() == null ? Colors.white54 : Colors.white,
                  darkColor:
                      _getMessage() == null ? Colors.black54 : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        child: TextField(
          autofocus: true,
          controller: _controller,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 5,
          enabled: !_isSending,
          decoration: InputDecoration(
            labelText: "Escribe tu mensaje",
            prefixIcon: _isError
                ? const Icon(
                    Icons.error,
                    color: Colors.red,
                  )
                : null,
            suffixIcon: _isSending
                ? const Icon(
                    Icons.hourglass_empty,
                  )
                : IconButton(
                    onPressed: () => _send(),
                    tooltip: "Send",
                    icon: Icon(
                      Icons.send,
                      color: appData.themeColor,
                    ),
                  ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}
