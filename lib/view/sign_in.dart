import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'login.dart';

// Pantalla de primera vez que se abre la aplicación
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Icon(Icons.store_outlined, size: 30),
      ),
      body: _drawBody(),
    );
  }

  Widget _drawBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _drawMobile();
        } else {
          return _drawDesktop();
        }
      },
    );
  }

  Widget _drawDesktop(){
    return Row(
      children: [
        Expanded(
          child: _welcomeText2(),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _botonSignIn2(),
              _botonLogin2(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _drawMobile() {
    return Column(
      children: [
        _welcomeText(),
        _botonSignIn(),
        _botonLogin(),
      ],
    );
  }

  Widget _welcomeText() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a Tiger Place!',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ya sea que estés buscando vender algo o simplemente quieras ver, ¡has llegado al lugar ideal!',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonSignIn() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navegar a la pantalla de registro
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SignUp()));
      },
      icon: const Icon(Icons.account_box_outlined),
      label: const Text('Crea una cuenta ahora!'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        minimumSize: const Size(88, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget _botonLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ya tienes una cuenta?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        TextButton(
          onPressed: () {
            // Navegar a la pantalla de login
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
          child: const Text(
            'Inicia sesión!',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _welcomeText2() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a Tiger Place!',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ya sea que estés buscando vender algo o simplemente quieras ver, ¡has llegado al lugar ideal!',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonSignIn2() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navegar a la pantalla de registro
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SignUp()));
      },
      icon: const Icon(Icons.account_box_outlined),
      label: const Text('Crea una cuenta ahora!'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        minimumSize: const Size(88, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget _botonLogin2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ya tienes una cuenta?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        TextButton(
          onPressed: () {
            // Navegar a la pantalla de login
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
          child: const Text(
            'Inicia sesión!',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
