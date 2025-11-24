import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final query = await db
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return query.docs.first.data();
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<void> registrar(String email, String password) async {
    try {
      await db.collection('usuarios').add({
        'email': email,
        'password': password,
      });
    } catch (e) {
      print('Error en registro: $e');
    }
  }
}
