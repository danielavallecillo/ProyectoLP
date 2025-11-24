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

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      final h = widget.habit!;
      nombreController.text = h.nombre;
      descripcionController.text = h.descripcion;
      minutosController.text = h.minutosPorDia.toString();
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
              decoration: const InputDecoration(labelText: 'Nombre del habito'),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
            TextField(
              controller: minutosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutos por dia'),
            ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _guardarHabito,
                    child: Text(esEdicion ? 'Guardar cambios' : 'Guardar'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarHabito() async {
    final user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    if (nombreController.text.trim().isEmpty ||
        minutosController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y minutos son obligatorios')),
      );
      return;
    }

    final minutos = int.tryParse(minutosController.text.trim()) ?? 0;

    setState(() => cargando = true);

    if (widget.habit == null) {
   
      final nuevo = HabitModel(
        id: '', 
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        minutosPorDia: minutos,
      );
      await habitsService.crearHabit(user.uid, nuevo);
    } else {
      
      final actualizado = HabitModel(
        id: widget.habit!.id,
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        minutosPorDia: minutos,
      );
      await habitsService.actualizarHabit(user.uid, actualizado);
    }

    setState(() => cargando = false);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
