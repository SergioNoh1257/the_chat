import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/router/app_router.dart';

class NotFound extends StatefulWidget {
  const NotFound({super.key});

  @override
  State<NotFound> createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFound> {
  late bool _isHoverLogo;

  @override
  void initState() {
    super.initState();

    _isHoverLogo = false;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => _isHoverLogo = true),
                onExit: (_) => setState(() => _isHoverLogo = false),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  curve: Curves.easeInOut,
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      color: _isHoverLogo
                          ? appData.themeColor.shade500
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      border: Border.all(
                        color: _isHoverLogo
                            ? Colors.transparent
                            : appData.themeColor.shade500,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurStyle: BlurStyle.outer,
                          color: appData.themeColor.shade200,
                          blurRadius: 4.0,
                        )
                      ]),
                  child: Center(
                    child: Text(
                      "404",
                      style: TextStyle(
                        color: _isHoverLogo
                            ? Colors.white
                            : appData.themeColor.shade500,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "No encontrado",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text("Regresar"),
                onPressed: () => context.goNamed(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
