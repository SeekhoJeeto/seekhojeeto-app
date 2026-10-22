import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over Firebase Auth so the rest of the app does not have to
/// care whether Firebase has been configured yet. If Firebase is missing the
/// app still runs (as a guest); login screens just show a friendly notice.
class AuthService {
  bool firebaseReady = false;

  User? get currentUser {
    if (!firebaseReady) return null;
    return FirebaseAuth.instance.currentUser;
  }

  Stream<User?> authStateChanges() {
    if (!firebaseReady) return const Stream<User?>.empty();
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<String?> signIn(String email, String password) async {
    if (!firebaseReady) return 'Login is not set up yet.';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed.';
    } catch (_) {
      return 'Sign in failed.';
    }
  }

  Future<String?> signUp(String email, String password) async {
    if (!firebaseReady) return 'Login is not set up yet.';
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed.';
    } catch (_) {
      return 'Sign up failed.';
    }
  }

  Future<void> signOut() async {
    if (firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }
}
