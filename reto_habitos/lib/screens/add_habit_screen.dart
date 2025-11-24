import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:reto_habitos/models/habit_model.dart';
import 'package:reto_habitos/services/habits_service.dart';

class AddHabitScreen extends StatefulWidget {

  final HabitModel? habit;

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController minutosController = TextEditingController();

  final HabitsService habitsService = HabitsService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      nombreController.text = widget.habit!.nombre;
      descripcionController.text = widget.habit!.descripcion;
      minutosController.text = widget.habit!.minutosPorDia.toString();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    minutosController.dispose();
    super.dispose();
  }

  Future<void> _guardarHabit() async {
    final user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final minutosTexto = minutosController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty || minutosTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final minutos = int.tryParse(minutosTexto);
    if (minutos == null || minutos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un numero valido de minutos')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final habit = HabitModel(
        id: widget.habit?.id ?? '',
        nombre: nombre,
        descripcion: descripcion,
        minutosPorDia: minutos,
      );

      if (widget.habit == null) {

        await habitsService.crearHabit(user.uid, habit);
      } else {

        await habitsService.actualizarHabit(user.uid, habit);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar habito: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Habito' : 'Agregar Habito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del habito',
              ),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
              ),
            ),
            TextField(
              controller: minutosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos por dia',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _guardarHabit,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(esEdicion ? 'Guardar cambios' : 'Guardar habito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
