import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:tigerplaceproject/controller/login_controller.dart';
import '../tools/tool.dart';
import 'home.dart';

// Ventana donde se muestra un formulario para iniciar sesión
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Llave para validar el formulario
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Icon(Icons.store_outlined, size: 30),
      ),
      body: drawLogin(),
    );
  }

  /// Método para dibujar el formulario de inicio de sesión
  Widget drawLogin() {
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets paddingValue = screenWidth > 600 ? const EdgeInsets.symmetric(horizontal: 200) : EdgeInsets.zero;
    return SingleChildScrollView(
      padding: paddingValue,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // Validad que el email no sea nulo o vacío
                if (Tool.isNullOrBlank(value!)) {
                  return 'Por favor, ingrese su correo electrónico';
                }
                // Validad que el email tenga un formato de email valido
                if (!Tool.isEmail(value)) {
                  return 'Por favor, ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                return Tool.isNullOrBlank(value!)
                    ? 'Por favor, ingrese su contraseña'
                    : null;
              },
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => FutureProgressDialog(
                        LoginController.autenticarUsuario(email, password),
                        message: const Text('Iniciando sesión'),
                      ),
                    ).then((value) => {
                          if (value != null)
                            {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                                (Route<dynamic> route) => false,
                              )
                            }
                          else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Correo electrónico o contraseña incorrectos o no verificados'),
                                ),
                              )
                            }
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                child: const Text('Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método para limpiar los campos de texto
  void clearTextFields() {
    _emailController.clear();
    _passwordController.clear();
  }
}
