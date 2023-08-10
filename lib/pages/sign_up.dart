import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/router/app_router.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final AppData appData = context.watch<AppData>();

  //Supabase instance
  final SupabaseClient _client = Supabase.instance.client;

  //Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Form Key for validations
  final _formKey = GlobalKey<FormState>();

  //Password is visible?
  bool _pwdVisible = false;

  String? _validateName() {
    final name = _nameController.value.text.trim();

    final List<String> sectionNames = name.split(" ");

    if (name.isEmpty) {
      return "El nombre es requerido";
    }

    if (name.length < 4 || name.length > 40) {
      return "Coloca tu nombre real";
    }

    if (sectionNames.length < 2 || sectionNames.length > 4) {
      return "Coloca nombre y apellidos";
    }

    return null;
  }

  String? _validateEmail() {
    String email = _emailController.value.text.trim();

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

  String? _validatePassword() {
    String pwd = _passwordController.value.text.trim();

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

  _signUp() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;

    bool isSignedUp = false;
    String? logData;

    try {
      final name = _nameController.value.text.trim();
      final email = _emailController.value.text.trim();
      final password = _passwordController.value.text.trim();

      //Hide current SnackBar if exists
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

      if (isValidForm) {
        List<String> nameArray = [];

        //Create name_array for search profiles
        for (int currentPos = 0; currentPos < name.length; currentPos++) {
          nameArray.add(name.substring(0, currentPos + 1));
        }

        //Create user
        final AuthResponse response = await _client.auth.signUp(
          email: email,
          password: password,
          data: {
            "name": name,
            "contacts_list": [],
            "profile_photo": null,
            "cover_photo": null,
          },
        );

        //Create row in "users" if response is not null
        if (response.user != null) {
          await _client.from("users").insert(
            {
              "name": name,
              "email": password,
              "uid": response.user!.id,
              "name_array": nameArray,
              "contacts_list": [],
              "admin": false,
            },
          );
        }

        logData = "Registro exitoso";
        isSignedUp = true;
      } else {
        logData = "Por favor, complete correctamente todos los datos";
      }

      //Handle Auth Exceptions
    } catch (e) {
      logData = "Ocurrió un error al registrarte. Intente más tarde";

      //Print result
    } finally {
      //Show new SnackBar
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text("$logData"),
        ),
      );

      //Return to Home if signUp is successful
      if (isSignedUp) {
        context.goNamed(Routes.home);
      }
    }
  }

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
          "Registrarse - Chat!",
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
                  //Name form
                  TextFormField(
                    //Controller
                    controller: _nameController,

                    decoration: const InputDecoration(
                      //Label
                      label: Text("Nombre de usuario*"),

                      //Example
                      helperText: "Nombre y apellido",

                      //Name icon
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                    ),

                    //Auto focus this node
                    autofocus: true,

                    //Set to name keyboard
                    keyboardType: TextInputType.name,

                    //Focus the next node if submitted
                    textInputAction: TextInputAction.next,

                    //Name Validator
                    validator: (_) => _validateName(),
                  ),

                  //Separator
                  const SizedBox(height: 10),

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

                    //Set to email keyboard
                    keyboardType: TextInputType.emailAddress,

                    //Focus the next node if submitted
                    textInputAction: TextInputAction.next,

                    //Email Validator
                    validator: (_) => _validateEmail(),
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
                    validator: (_) => _validatePassword(),
                  ),

                  //Separator
                  const SizedBox(height: 20),

                  //Button
                  ElevatedButton(
                    onPressed: () => _signUp(),
                    child: const Text("Registrarse"),
                  ),

                  //Separator
                  const SizedBox(height: 10),

                  //Button
                  TextButton(
                    onPressed: () => context.goNamed(Routes.login),
                    child: const Text("Iniciar sesión"),
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
