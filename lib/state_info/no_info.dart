import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class NoInfo extends StatelessWidget {
  const NoInfo({super.key});

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
              Icons.sentiment_very_dissatisfied,
              size: 50,
              color: appData.themeColor.shade500,
            ),
            const SizedBox(height: 5),
            const Text(
              "Oops...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text("Parece que no hay datos para mostrar"),
          ],
        ),
      ),
    );
  }
}
