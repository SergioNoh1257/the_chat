// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GetRichText {
  final String text;

  const GetRichText({required this.text});

  _launchUrl(String url) async {
    String launchToUrl = url;

    if (!launchToUrl.startsWith("https://")) {
      launchToUrl = "https://$launchToUrl";
    }

    Uri uri = Uri.parse(launchToUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      //No se puede abrir la url
    }
  }

  get getRichText {
    List<String> textSplitted = [];
    List<TextSpan> textRich = [];

    text.splitMapJoin(
      RegExp(
          r'((\._(.{1,})_\.)|(\.\*(.{1,})\*\.)|(\.\+(.{1,})\+\.)|(\.-(.{1,})-\.)|(\.\<(.{1,})\>\.))'),
      onMatch: (p0) {
        textSplitted.add("${p0[0]}");
        return "${p0[0]}";
      },
      onNonMatch: (p0) {
        textSplitted.add(p0);
        return p0;
      },
    );

    /* Values supported:
      ._abc_.
      .*abc*.
      .+abc+.
      .-abc-.
      .<https://abc.abc>.
      */
    for (var text in textSplitted) {
      if (text.contains(RegExp(r'(\._(.{1,})_\.)'))) {
        textRich.add(
          TextSpan(
            text: text.substring(2, text.length - 2),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (text.contains(RegExp(r'(\.\*(.{1,})\*\.)'))) {
        textRich.add(
          TextSpan(
            text: text.substring(2, text.length - 2),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (text.contains(RegExp(r'(\.\+(.{1,})\+\.)'))) {
        textRich.add(
          TextSpan(
            text: text.substring(2, text.length - 2),
            semanticsLabel: text.substring(2, text.length - 2),
            style: const TextStyle(
              backgroundColor: Colors.white,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (text.contains(RegExp(r'(\.\-(.{1,})-\.)'))) {
        textRich.add(
          TextSpan(
            text: text.substring(2, text.length - 2),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
      } else if (text.contains(RegExp(r'(\.\<(.{1,})\>\.)'))) {
        textRich.addAll(
          [
            TextSpan(
              text: text.substring(2, text.length - 2),
              mouseCursor: SystemMouseCursors.click,
              semanticsLabel: text.substring(2, text.length - 2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTapUp = (_) async {
                  await _launchUrl(text.substring(2, text.length - 2));
                },
            ),
            const TextSpan(text: " "),
            const TextSpan(
              text: "Página externa",
              style: TextStyle(
                color: Colors.red,
                backgroundColor: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        textRich.add(
          TextSpan(text: text),
        );
      }
    }

    if (textRich.isNotEmpty && textRich.first.text == "") {
      textRich.remove(textRich.first);
    }

    if (textRich.isNotEmpty && textRich.last.text == "") {
      textRich.removeLast();
    }
    return textRich;
  }
}
