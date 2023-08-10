import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldMessengerState> smKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

//Global SnackBar
abstract class GlobalSnackBar {
  static show(
    String text, {
    IconData? icon,
    Color? backgroundColor,
    bool? showCloseIcon,
  }) {
    smKey.currentState?.hideCurrentSnackBar();
    smKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Visibility(
              visible: icon != null,
              child: icon != null
                  ? Icon(
                      icon,
                      color: (backgroundColor?.computeLuminance() ??
                                  const Color.fromARGB(255, 32, 32, 32)
                                      .computeLuminance()) >
                              0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : const SizedBox(),
            ),
            Visibility(
              visible: icon != null,
              child: const SizedBox(width: 10),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: (backgroundColor?.computeLuminance() ??
                              const Color.fromARGB(255, 32, 32, 32)
                                  .computeLuminance()) >
                          0.5
                      ? Colors.black
                      : Colors.white,
                  fontFamily: "Questrial",
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            backgroundColor ?? const Color.fromARGB(255, 32, 32, 32),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: showCloseIcon,
        closeIconColor: (backgroundColor?.computeLuminance() ??
                    const Color.fromARGB(255, 32, 32, 32).computeLuminance()) >
                0.5
            ? Colors.black
            : Colors.white,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 10),
        elevation: 4.0,
      ),
    );
  }

  static hideCurrent() {
    smKey.currentState?.hideCurrentSnackBar();
  }

  static removeCurrent() {
    smKey.currentState?.removeCurrentSnackBar();
  }

  static clearAll() {
    smKey.currentState?.clearSnackBars();
  }
}

//Global Navigator
abstract class GlobalNavigator {
  static showDialogWithContent({
    Widget? content,
  }) {
    showDialog(
      context: navKey.currentContext!,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 100),
            child: content,
          ),
        );
      },
    );
  }

  static goNamed(
    name, {
    Map<String, String>? pathParameters,
    Object? extra,
  }) {
    navKey.currentContext!
        .goNamed(name, pathParameters: pathParameters ?? {}, extra: extra);
  }
}
