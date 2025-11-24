//Aminta Jackeline Bautista Osorto - 20192030205
//Daniela Alejandra Vallecillo Flores - 20212020968
//Nathaly Sujey Rodriguez Maldonado - 20212020675

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:reto_habitos/screens/login_screen.dart';
import 'package:reto_habitos/screens/home_screen.dart';
import 'package:reto_habitos/screens/register_screen.dart';
import 'package:reto_habitos/screens/add_habit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBXc46OeNtnsI-pI7d3Tp_tT10dbddIET4",
        authDomain: "proyectolp-reto-habitos.firebaseapp.com",
        projectId: "proyectolp-reto-habitos",
        storageBucket:"proyectolp-reto-habitos.firebasestorage.app",
        messagingSenderId: "114059348590",
        appId:  "1:114059348590:web:9d5ffc695361015414b47f",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reto Habitos',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/addHabit': (context) => AddHabitScreen(),
      },
    );
  }
}