import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:reto_habitos/models/habit_model.dart';
import 'package:reto_habitos/services/habits_service.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habit; // null = crear, con datos = editar

  const AddHabitScreen({Key? key, this.habit}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _minutosController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _habitsService = HabitsService();
  final _auth = FirebaseAuth.instance;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Si viene un hábito para editar, llenamos los campos
    if (widget.habit != null) {
      _nombreController.text = widget.habit!.nombre;
      _descripcionController.text = widget.habit!.descripcion;
      _minutosController.text = widget.habit!.minutosPorDia.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _minutosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar hábito' : 'Agregar hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del hábito'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minutosController,
                decoration: const InputDecoration(labelText: 'Minutos por día'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa los minutos por día';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) {
                    return 'Ingresa un número mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onGuardarPressed,
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(esEdicion ? 'Guardar cambios' : 'Guardar hábito'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onGuardarPressed() async {
    // Validación básica
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final minutos = int.parse(_minutosController.text.trim());

    setState(() => _isSaving = true);

    try {
      // DEBUG: para ver en consola qué pasa
      print('--- GUARDAR HÁBITO ---');
      print('userId: ${user.uid}');
      print('nombre: $nombre');
      print('descripcion: $descripcion');
      print('minutos: $minutos');
      print('es edición: ${widget.habit != null}');

      final habit = HabitModel(
        id: widget.habit?.id ?? '',
        nombre: nombre,
        descripcion: descripcion,
        minutosPorDia: minutos,
      );

      // Timeout de 10 segundos para evitar “carga infinita”
      if (widget.habit == null) {
        await _habitsService
            .crearHabit(user.uid, habit)
            .timeout(const Duration(seconds: 10));
      } else {
        await _habitsService
            .actualizarHabit(user.uid, habit)
            .timeout(const Duration(seconds: 10));
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.habit == null
                ? 'Hábito creado correctamente'
                : 'Hábito actualizado correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('La operación tardó demasiado. Revisa tu conexión / Firestore'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el hábito: $e')),
      );
      print('ERROR guardar hábito: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
