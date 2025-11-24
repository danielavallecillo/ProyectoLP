import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reto_habitos/models/habit_model.dart';

class HabitsService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<List<HabitModel>> obtenerHabitos(String userId) {
    return db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('nombre')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => HabitModel.fromDoc(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // Crear un habito nuevo
  Future<void> crearHabit(String userId, HabitModel habit) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .add(habit.toMap());
  }

  // Actualizar un habito existente
  Future<void> actualizarHabit(String userId, HabitModel habit) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toMap());
  }

  // Eliminar un habito
  Future<void> eliminarHabit(String userId, String habitId) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .delete();
  }
}
