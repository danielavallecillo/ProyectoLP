import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';
import '../services/habits_service.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habitExistente;

  const AddHabitScreen({super.key, this.habitExistente});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController minutosController = TextEditingController();

  final HabitsService habitsService = HabitsService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.habitExistente != null) {
      nombreController.text = widget.habitExistente!.nombre;
      descripcionController.text = widget.habitExistente!.descripcion;
      minutosController.text =
          widget.habitExistente!.minutosPorDia.toString();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    minutosController.dispose();
    super.dispose();
  }

  Future<void> guardarHabit() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay usuario logueado')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final minutos = int.tryParse(minutosController.text.trim()) ?? 0;

    try {
      if (widget.habitExistente == null) {
        // Crear
        final habit = HabitModel(
          id: '', // Firestore generara el id
          nombre: nombre,
          descripcion: descripcion,
          minutosPorDia: minutos,
        );
        await habitsService.crearHabit(user!.uid, habit);
      } else {
        // Editar
        final habitEditado = HabitModel(
          id: widget.habitExistente!.id,
          nombre: nombre,
          descripcion: descripcion,
          minutosPorDia: minutos,
        );
        await habitsService.actualizarHabit(user!.uid, habitEditado);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el habito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habitExistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar habito' : 'Agregar habito'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Descripcion'),
              ),
              TextFormField(
                controller: minutosController,
                decoration:
                    InputDecoration(labelText: 'Minutos por dia'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa los minutos por dia';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Debe ser un numero';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarHabit,
                child: Text(esEdicion ? 'Guardar cambios' : 'Crear habito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
