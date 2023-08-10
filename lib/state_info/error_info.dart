import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class ErrorInfo extends StatefulWidget {
  final void Function()? retry;
  const ErrorInfo({super.key, this.retry});

  @override
  State<ErrorInfo> createState() => _ErrorInfoState();
}

class _ErrorInfoState extends State<ErrorInfo> {
  bool _showRetryButton = false;
  late Timer? _retryCooldown;

  @override
  void initState() {
    _retryCooldown = Timer(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        setState(() => _showRetryButton = true);
      }
      _retryCooldown?.cancel();
    });
    super.initState();
  }

  @override
  void dispose() {
    _retryCooldown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_very_dissatisfied_outlined,
              size: 50,
              color: appData.themeColor.shade500,
            ),
            const SizedBox(height: 5),
            const Text(
              "Oh no...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text("Ha ocurrido un error"),
            const SizedBox(height: 10),
            Visibility(
              visible: widget.retry != null && !_showRetryButton,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Visibility(
              visible: widget.retry != null && _showRetryButton,
              child: ElevatedButton(
                onPressed: () => widget.retry!(),
                child: const Text("Reintentar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
