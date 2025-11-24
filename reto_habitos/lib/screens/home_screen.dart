import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habit_model.dart';
import '../services/habits_service.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitsService habitsService = HabitsService();
  String userId = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de habitos'),
      ),
      body: userId.isEmpty
          ? const Center(
              child: Text('No hay usuario autenticado'),
            )
          : StreamBuilder<List<HabitModel>>(
              stream: habitsService.obtenerHabitos(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final habits = snapshot.data ?? [];

                if (habits.isEmpty) {
                  return const Center(
                    child: Text('Aun no tienes habitos'),
                  );
                }

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];

                    return Card(
                      child: ListTile(
                        title: Text(habit.nombre),
                        subtitle: Text(
                          '${habit.descripcion}\nMinutos por dia: ${habit.minutosPorDia}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddHabitScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await habitsService.eliminarHabit(
                                  userId,
                                  habit.id,
                                );
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
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
