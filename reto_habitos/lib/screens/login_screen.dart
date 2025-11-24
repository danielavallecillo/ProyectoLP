import 'package:flutter/material.dart';
import 'package:reto_habitos/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesion')),
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

                final user = await authService.login(
                  email.text.trim(),
                  password.text.trim(),
                );

                if (user != null) {
            
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
           
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
