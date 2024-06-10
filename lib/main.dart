import 'package:flutter/material.dart';
import 'package:tigerplaceproject/controller/login_controller.dart';
import 'package:tigerplaceproject/view/home.dart';
import 'view/sign_in.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiger Place',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: option(),
      //home: const Home(),
    );
  }

  Widget option() {
    if (LoginController.estaLogueado()) {
      return const Home();
    } else {
      return const SignIn();
    }
  }
}
