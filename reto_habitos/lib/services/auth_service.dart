import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuarioActual => _auth.currentUser;

  Future<User?> registrar(String email, String password) async {
    try {

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {

      print('Error al registrar: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error desconocido al registrar: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesion: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error desconocido al iniciar sesion: $e');
      return null;
    }
  }

  // Cerrar sesion
  Future<void> logout() async {
    await _auth.signOut();
  }
}
