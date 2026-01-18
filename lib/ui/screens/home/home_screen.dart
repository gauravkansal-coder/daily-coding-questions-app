import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/providers/auth_provider.dart';
import 'package:daily_coding_questions_app/providers/question_provider.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';
import 'package:daily_coding_questions_app/ui/screens/home/problem_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We don't need initState or _loadData anymore because
  // the StreamBuilder + addPostFrameCallback handles the loading logic automatically.

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final questionProv = Provider.of<QuestionProvider>(context);

    return StreamBuilder<UserModel>(
      // Listen to the user's streak and solved history in real-time
      stream: FirestoreService().getUserStream(auth.user?.uid ?? ''),
      builder: (context, snapshot) {
        // 1. Check for Errors
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text("Error loading user data")));
        }

        // 2. Check for Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // 3. Logic Trigger: Once User loads, fetch the Question (if missing)
        if (user != null &&
            questionProv.todayQuestion == null &&
            !questionProv.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            questionProv.loadDailyQuestion(user);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Daily Challenge"),
            actions: [
              // Streak Badge
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${user.currentStreak}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              // Logout
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.signOut(),
              ),
            ],
          ),
          body: _buildBody(questionProv, user),
        );
      },
    );
  }

  Widget _buildBody(QuestionProvider provider, UserModel? user) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.todayQuestion == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No question for today yet!"),
            Text("Check back later."),
          ],
        ),
      );
    }

    return ProblemView(
      question: provider.todayQuestion!,
      isSolved: provider.isSolvedToday,
      onSolve: () {
        if (user != null) {
          provider.submitAnswer(user.uid);
        }
      },
    );
  }
}
