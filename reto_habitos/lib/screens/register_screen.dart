import 'package:flutter/material.dart';
import 'package:reto_habitos/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService authService = AuthService();

  bool cargando = false;

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
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
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

                      setState(() => cargando = true);

                      final user = await authService.registrar(
                        email.text.trim(),
                        password.text.trim(),
                      );

                      setState(() => cargando = false);

                      if (user != null) {
                      
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario registrado, inicia sesion'),
                          ),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                       
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error al registrar, revisa el correo o la contrasena',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Registrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
