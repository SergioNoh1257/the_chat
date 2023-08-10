import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/router/app_router.dart';
import 'package:the_chat/scaffold/app_bar.dart';

class PreSignOut extends StatefulWidget {
  final int status;
  const PreSignOut({super.key, required this.status});

  @override
  State<PreSignOut> createState() => _PreSignOutState();
}

class _PreSignOutState extends State<PreSignOut> {
  final _client = Supabase.instance.client;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _client.auth.signOut();
      } catch (_) {
        GlobalSnackBar.show(
          "No se pudo cerrar sesión, intente más tarde",
          icon: Icons.not_interested,
          backgroundColor: Colors.pink,
        );
      } finally {
        context.goNamed(Routes.home);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: "Cerrando sesión",
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 75.0,
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 10),
              Text("Espere..."),
            ],
          ),
        ),
      ),
    );
  }
}
