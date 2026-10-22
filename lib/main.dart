import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthService();
  try {
    await Firebase.initializeApp();
    auth.firebaseReady = true;
  } catch (_) {
    // Firebase not configured yet (no google-services.json). The app still
    // works as a guest; add Firebase later to enable accounts and saving.
    auth.firebaseReady = false;
  }

  final state = AppState();
  await state.init();

  final progress = ProgressService(auth);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<ProgressService>.value(value: progress),
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
      home: const HomeScreen(),
    );
  }
}
