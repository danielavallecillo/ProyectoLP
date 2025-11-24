import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reto_habitos/models/habit_model.dart';
import 'package:reto_habitos/services/habits_service.dart';
import 'package:reto_habitos/screens/add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitsService habitsService = HabitsService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? userId;

  @override
  void initState() {
    super.initState();
    userId = auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("No hay usuario autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Habitos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: StreamBuilder<List<HabitModel>>(
        stream: habitsService.obtenerHabitos(userId!),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final habitos = snapshot.data ?? [];

          if (habitos.isEmpty) {
            return const Center(child: Text("Aún no tienes hábitos."));
          }

          return ListView.builder(
            itemCount: habitos.length,
            itemBuilder: (context, index) {
              final habit = habitos[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(habit.nombre),
                  subtitle: Text(
                    "${habit.descripcion}\nMinutos por día: ${habit.minutosPorDia}",
                  ),
                  isThreeLine: true,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddHabitScreen(habit: habit),
                      ),
                    );
                  },

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddHabitScreen(habit: habit),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _confirmarEliminarHabit(habit);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmarEliminarHabit(HabitModel habit) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar hábito"),
          content: Text(
            '¿Seguro que deseas eliminar el hábito "${habit.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar == true && userId != null) {
      await habitsService.eliminarHabit(userId!, habit.id);
    }
  }
}
