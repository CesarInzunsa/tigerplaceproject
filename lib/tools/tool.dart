import 'package:flutter/material.dart';

class Tool {
  /// Funcion para validar si un texto es nulo, vacío o solo contiene espacios en blanco
  static bool isNullOrBlank(String text) {
    return text.trim().isEmpty;
  }

  /// Expresión regular para validar un email
  static bool isEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@ittepic\.edu\.mx$').hasMatch(email);
  }

  static ButtonStyle getButtonStyle(String type) {
    switch (type) {
      case 'primary':
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        );
      case 'cancel':
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        );
      case 'secondary':
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          // padding: const EdgeInsets.symmetric(horizontal: 16),
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.all(Radius.circular(4)),
          // ),
        );
      default:
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        );
    }
  }

  static void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String getDefaultProfileImage() {
    return 'https://firebasestorage.googleapis.com/v0/b/tigerplace-a9398.appspot.com/o/escudo_itt_grande.png?alt=media&token=015a7f02-fd15-4770-a6e5-340331f5a211';
  }
}
