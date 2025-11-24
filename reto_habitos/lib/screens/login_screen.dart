import 'package:flutter/material.dart';
import 'package:reto_habitos/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Correo',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contrasena',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authService = AuthService();

                final user = await authService.login(
                  email.text.trim(),
                  password.text.trim(),
                );

                if (user != null) {
                  // Login correcto -> ir al Home
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamed(context, '/home');
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Credenciales incorrectas'),
                    ),
                  );
                }
              },
              child: const Text('Iniciar Sesion'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Crear Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
