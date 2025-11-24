//Aminta Jackeline Bautista Osorto - 20192030205
//Daniela Alejandra Vallecillo Flores - 20212020968
//Nathaly Sujey Rodriguez Maldonado - 20212020675

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){

    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'App habitos',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App habitos'),
        ),
        body: const Center(
          child: Text(
            'La apliacion ha sido iniciada correctamente',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
