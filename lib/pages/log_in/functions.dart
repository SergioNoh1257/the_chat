import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/pages/log_in/log_in.dart';
import 'package:the_chat/router/app_router.dart';

mixin LogInMixin on State<LogIn> {
  final _client = Supabase.instance.client;

  ///Validate email and return null if email is correctly formatted
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "El campo es requerido";
    }

    if (!email.contains(
      RegExp(
          r'^(([^<>()\[\]\\.,;:\s@”]+(\.[^<>()\[\]\\.,;:\s@”]+)*)|(“.+”))@((\[[0–9]{1,3}\.[0–9]{1,3}\.[0–9]{1,3}\.[0–9]{1,3}])|(([a-zA-Z\-0–9]+\.)+[a-zA-Z]{2,}))$'),
    )) {
      return "Usa un email válido";
    }

    return null;
  }

  ///Validate password and return null if password is correctly formatted

  String? validatePassword(String pwd) {
    if (pwd.isEmpty) {
      return "La contraseña es requerida";
    }

    if (pwd.length < 8 || pwd.length > 20) {
      return "Usa una contraseña de entre 8 y 20 caracteres";
    }

    if (pwd.contains(" ")) {
      return "Usa una contraseña sin espacios";
    }

    if (!pwd.contains(RegExp(r'[A-Z]', caseSensitive: true))) {
      return "Usa al menos un caracter en mayúscula";
    }

    if (!pwd.contains(RegExp(r'[0-9]'))) {
      return "Usa al menos un número";
    }

    return null;
  }

  //Logs user if credentials are valid
  logIn(email, password) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      //Show Dialog of user logged
      GlobalSnackBar.show(
        "Sesión iniciada como ${response.user?.userMetadata?["name"]}",
        icon: Icons.account_circle,
        backgroundColor: Colors.green,
      );

      //Return to Home
      GlobalNavigator.goNamed(Routes.home);
    } on AuthException catch (e) {
      //Show Auth error
      GlobalSnackBar.show(
        "No se pudo iniciar sesión: ${e.message}",
        icon: Icons.not_interested,
        backgroundColor: Colors.orange,
      );
    } catch (_) {
      //Show other errors
      GlobalSnackBar.show(
        "No se pudo iniciar sesión debido a un error desconocido",
        icon: Icons.question_mark,
        backgroundColor: Colors.yellow,
      );
    }
  }
}
