// DANIELA: pantalla de registro de usuario

import 'package:flutter/material.dart';
import 'package:reto_habitos/services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasena'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (email.text.trim().isEmpty ||
                    password.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos'),
                    ),
                  );
                  return;
                }

                await authService.registrar(
                  email.text.trim(),
                  password.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario registrado, inicia sesion'),
                  ),
                );

                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
