import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthService();
  try {
    await Firebase.initializeApp();
    auth.firebaseReady = true;
  } catch (_) {
    // Firebase not configured yet (no google-services.json). The app still
    // works as a guest; add Firebase later to enable accounts.
    auth.firebaseReady = false;
  }

  final state = AppState();
  await state.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        Provider<AuthService>.value(value: auth),
      ],
      child: const SeekhoJeetoApp(),
    ),
  );
}

class SeekhoJeetoApp extends StatelessWidget {
  const SeekhoJeetoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seekho Jeeto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF138808),
      ),
      home: const RootGate(),
    );
  }
}

/// Shows login when Firebase is ready, otherwise goes straight to the app.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    if (!auth.firebaseReady) return const HomeScreen();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
