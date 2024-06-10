import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:tigerplaceproject/controller/login_controller.dart';

import '../model/user_model.dart';
import '../tools/tool.dart';

// Formulario para crear una cuenta
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Crear un controlador para cada campo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _typeController =
      TextEditingController(text: "Cliente");

  // Array de tipos de usuario
  final List<String> _types = ['Cliente', 'Vendedor'];

  // Crear una clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 30),
            Text('Crear cuenta'),
          ],
        ),
      ),
      body: _displayForm(),
    );
  }

  Widget _displayForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets paddingValue = screenWidth > 600 ? const EdgeInsets.symmetric(horizontal: 200) : EdgeInsets.zero;
    return SingleChildScrollView(
      padding: paddingValue,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _displayInput('Nombre', _nameController),
            _displayInput('Nombre de Usuario', _userNameController),
            _displayEmailInput('Correo Institucional', _emailController),
            _displayPasswordInput('Contraseña', _passwordController),
            _displayCombo(),
            _displayActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _displayInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayEmailInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          if (!Tool.isEmail(value)) {
            return 'Por favor, ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayPasswordInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayCombo() {
    return DropdownButtonFormField(
      value: _typeController.text,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      items: _types.map((String type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        _typeController.text = value.toString();
      },
      decoration: const InputDecoration(
        labelText: 'Tipo de usuario',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _displayActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _displayCreateAccountButton(),
          _displayCancelButton(),
        ],
      ),
    );
  }

  Widget _displayCreateAccountButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _createNewAccount();
        }
      },
      style: Tool.getButtonStyle('primary'),
      child: const Text('Crear cuenta'),
    );
  }

  Widget _displayCancelButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: Tool.getButtonStyle('cancel'),
      child: const Text('Cancelar'),
    );
  }

  Future<void> _createNewAccount() async {
    // Obtener los valores de los campos
    String name = _nameController.text;
    String userName = _userNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String type = _typeController.text;

    // Crear objeto de tipo User
    final UserModel newUser = UserModel.newUser(
      name: name,
      userName: userName,
      email: email,
      password: password,
      type: type,
    );

    // Dialogo de progreso
    showDialog(
      context: context,
      builder: (BuildContext context) => FutureProgressDialog(
        LoginController.createUser(newUser),
        message: const Text('Creando cuenta'),
      ),
    ).then(
      (value) {
        if (value != null) {
          // Limpiar los campos
          _clearTextFields();
          // Mostrar mensaje de éxito
          Tool.showMessage(
              'Cuenta creada exitosamente, Inicie sesión', context);
          // Regresar a la pantalla de login
          Navigator.pop(context);
        } else {
          Tool.showMessage(
            'Ocurrio un error al crear la cuenta o el correo o usuario ya estan registrados',
            context,
          );
        }
      },
    );
  }

  void _clearTextFields() {
    _nameController.clear();
    _userNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _typeController.text = "Cliente";
  }
}
