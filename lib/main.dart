import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:daily_coding_questions_app/firebase_options.dart';
import 'package:daily_coding_questions_app/providers/auth_provider.dart';
import 'package:daily_coding_questions_app/providers/question_provider.dart';
import 'package:daily_coding_questions_app/ui/screens/auth/login_screen.dart';
import 'package:daily_coding_questions_app/ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
      ],
      child: MaterialApp(
        title: 'Daily Coder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// Authentication Wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
