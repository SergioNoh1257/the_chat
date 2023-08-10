import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/connectivity/global.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/pages/log_in/functions.dart';
import 'package:the_chat/router/app_router.dart';

class LogIn extends Connectivity {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends ConnectivityState<LogIn> with LogInMixin {
  late final AppData appData = context.watch<AppData>();

  //Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Form Key for validations
  final _formKey = GlobalKey<FormState>();

  //Password is visible?
  bool _pwdVisible = false;
  Icon _getIcon() {
    return _pwdVisible
        ? const Icon(Icons.visibility_off)
        : const Icon(Icons.visibility);
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Iniciar sesión - Chat!",
          style: TextStyle(
            color: appData.determineColor(
              condition: "themeColor",
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: appData.themeColor.shade500,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          constraints: const BoxConstraints(
            maxHeight: 400,
            maxWidth: 400,
          ),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            color: currentColor.computeLuminance() > 0.5
                ? Colors.white
                : const Color(0xFF3F3F3F),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                children: [
                  //Email form
                  TextFormField(
                    //Controller
                    controller: _emailController,

                    decoration: const InputDecoration(
                      //Label
                      label: Text("Correo electrónico*"),

                      //Example
                      helperText: "Ejemplo: example@example.com",

                      //Email icon
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                    ),

                    //Auto focus this node
                    autofocus: true,

                    //Set to email keyboard
                    keyboardType: TextInputType.emailAddress,

                    //Focus the next node if submitted
                    textInputAction: TextInputAction.next,

                    //Email Validator
                    validator: (_) => validateEmail(
                      _emailController.value.text.trim(),
                    ),
                  ),

                  //Separator
                  const SizedBox(height: 10),

                  //Password field
                  TextFormField(
                    //Controller
                    controller: _passwordController,

                    decoration: InputDecoration(
                      //Label
                      label: const Text("Contraseña*"),

                      //Example
                      helperText: "Usa una contraseña segura",

                      //Icon for visibility
                      prefixIcon: GestureDetector(
                        onTap: () {
                          setState(() => _pwdVisible = !_pwdVisible);
                        },
                        child: _getIcon(),
                      ),
                    ),

                    //Password settings
                    obscureText: !_pwdVisible,

                    //Set to password keyboard
                    keyboardType: TextInputType.visiblePassword,

                    //Hide keyboard if submitted
                    textInputAction: TextInputAction.done,

                    //Password Validator
                    validator: (_) => validatePassword(
                      _passwordController.value.text.trim(),
                    ),
                  ),

                  //Separator
                  const SizedBox(height: 20),

                  //Button
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        logIn(
                          _emailController.value.text.trim(),
                          _passwordController.value.text.trim(),
                        );
                      } else {
                        GlobalSnackBar.show(
                          "Complete todos los campos",
                          icon: Icons.close,
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    child: const Text("Iniciar sesión"),
                  ),

                  //Separator
                  const SizedBox(height: 10),

                  //Button
                  TextButton(
                    onPressed: () => context.goNamed(Routes.signup),
                    child: const Text("Registrarse"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
