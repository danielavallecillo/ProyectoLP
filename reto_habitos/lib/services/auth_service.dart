import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en login: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error desconocido en login: $e');
      return null;
    }
  }

  Future<User?> registrar(String email, String password) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en registrar: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error desconocido en registrar: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  User? get usuarioActual => auth.currentUser;
}
