import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';

class ProfileImages extends StatelessWidget {
  final String? profilePhoto;
  final String? coverPhoto;

  const ProfileImages({
    super.key,
    this.profilePhoto,
    this.coverPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.width > 1000 ? size.width * 0.25 : 250,
      width: size.width,
      child: Stack(
        children: [
          SizedBox(
            height: size.width > 1000 ? size.width * 0.25 : 250,
            width: size.width,
            child: Material(
              color: appData.themeColor.shade300,
              elevation: 4.0,
              child: Image.network(
                "$coverPhoto",
                frameBuilder: (_, child, frame, ____) {
                  return AnimatedOpacity(
                    opacity: frame != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: child,
                  );
                },
                errorBuilder: (context, __, ___) => Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Sin foto de portada",
                      style: TextStyle(
                        color: appData.determineColor(
                          background: appData.themeColor.shade300,
                          condition: "custom",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment:
                size.width > 1000 ? Alignment.centerLeft : Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(20),
              height: size.width > 1000 ? size.width * 0.25 : 250,
              width: size.width > 1000 ? size.width * 0.25 : 250,
              child: Material(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                type: MaterialType.circle,
                color: appData.themeColor.shade100,
                elevation: 4.0,
                child: Image.network(
                  "$profilePhoto",
                  frameBuilder: (_, child, frame, ____) {
                    return AnimatedOpacity(
                      opacity: frame != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: child,
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 50,
                      color: appData.determineColor(
                          background: appData.themeColor.shade100,
                          condition: "custom"),
                    ),
                  ),
                  filterQuality: FilterQuality.low,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
