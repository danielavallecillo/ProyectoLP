import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:reto_habitos/models/habit_model.dart';
import 'package:reto_habitos/services/habits_service.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habit; // null = crear, no null = editar

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _minutosController = TextEditingController();

  final HabitsService _habitsService = HabitsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    // Si viene un hábito, rellenamos para modo editar
    if (widget.habit != null) {
      _nombreController.text = widget.habit!.nombre;
      _descripcionController.text = widget.habit!.descripcion;
      _minutosController.text = widget.habit!.minutosPorDia.toString();
    }
  }

  Future<void> _guardarHabit() async {
    if (_guardando) return;

    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final minutosStr = _minutosController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty || minutosStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final minutos = int.tryParse(minutosStr);
    if (minutos == null || minutos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minutos por día debe ser un número mayor que 0')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      if (widget.habit == null) {
        // ---------- CREAR HÁBITO NUEVO ----------
        final nuevoHabit = HabitModel(
          id: '', // Firestore genera el id; no lo usamos aquí
          nombre: nombre,
          descripcion: descripcion,
          minutosPorDia: minutos,
        );

        await _habitsService.crearHabit(user.uid, nuevoHabit);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito creado correctamente')),
        );
      } else {
        // ---------- EDITAR HÁBITO EXISTENTE ----------
        final habitActualizado = HabitModel(
          id: widget.habit!.id, // importante para actualizar el doc correcto
          nombre: nombre,
          descripcion: descripcion,
          minutosPorDia: minutos,
        );

        await _habitsService.actualizarHabit(user.uid, habitActualizado);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito actualizado')),
        );
      }

      if (mounted) {
        Navigator.pop(context); // volvemos al Home
      }
    } catch (e) {
      // Cualquier error de Firestore / red / etc.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar hábito: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEditar ? 'Editar Hábito' : 'Agregar Hábito'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del hábito'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _minutosController,
              decoration: const InputDecoration(labelText: 'Minutos por día'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            _guardando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _guardarHabit,
                    child: Text(esEditar ? 'Guardar cambios' : 'Guardar hábito'),
                  ),
          ],
        ),
      ),
    );
  }
}
