import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/funcionalities/rich_text.dart';
import 'package:the_chat/app_data/app_data.dart';

class CustomWindow {
  CustomWindow();

  showWindow(
    BuildContext context,
    Widget child, {
    String title = "Window",
    bool titleRichText = false,
    double maxWidth = 400,
    double minHeight = 50,
    void Function()? onButtonClose,
    Alignment textAlign = Alignment.centerLeft,
  }) {
    return showDialog(
      context: context,
      builder: (window) {
        final appData = Provider.of<AppData>(window);
        return Dialog(
          insetAnimationDuration: const Duration(milliseconds: 250),
          insetAnimationCurve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          elevation: 10,
          shadowColor: appData.themeColor.shade500,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          insetPadding: const EdgeInsets.all(15),
          child: GestureDetector(
            onTap: () => Navigator.pop(window),
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minHeight: minHeight,
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                              alignment: Alignment.center,
                              child: Text.rich(
                                TextSpan(
                                    children:
                                        GetRichText(text: title).getRichText),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Ink(
                          decoration: BoxDecoration(
                            color: appData.themeColor.shade500,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(window),
                            icon: Icon(
                              Icons.close,
                              color: appData.themeColor.shade500
                                          .computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
