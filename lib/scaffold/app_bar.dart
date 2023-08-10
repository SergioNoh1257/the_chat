import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final String? title;
  final List<Widget>? actions;
  const CustomAppBar(
      {super.key, this.title, this.actions, required this.backgroundColor});

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      elevation: 4.0,
      shadowColor: backgroundColor,
      backgroundColor: backgroundColor,
      foregroundColor: backgroundColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white,
      title: title != null && title!.isNotEmpty
          ? Text(
              title!,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
