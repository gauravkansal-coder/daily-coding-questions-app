import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/providers/auth_provider.dart';
import 'package:daily_coding_questions_app/providers/question_provider.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';
import 'package:daily_coding_questions_app/ui/screens/home/problem_view.dart';
import 'package:daily_coding_questions_app/ui/screens/profile/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final questionProv = Provider.of<QuestionProvider>(context);

    // Listen to the user's streak and solved history in real-time
    return StreamBuilder<UserModel>(
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
              // STREAK BADGE (Clickable)
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatsScreen(user: user),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.deepOrange, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${user.currentStreak}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // LOGOUT BUTTON
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // FIX: Clear the question data from memory BEFORE signing out
                  // This ensures the next user doesn't see the old user's "Solved" screen.
                  Provider.of<QuestionProvider>(context, listen: false)
                      .clearState();
                  auth.signOut();
                },
              ),
            ],
          ),
          body: _buildBody(questionProv, user),
        );
      },
    );
  }

  Widget _buildBody(QuestionProvider provider, UserModel? user) {
    // A. Loading State
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // B. No Question Found (Rest Day)
    if (provider.todayQuestion == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime, size: 80, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            const Text(
              "No question for today!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Check back tomorrow to keep your streak."),
          ],
        ),
      );
    }

    // C. Question Loaded -> Show Problem View
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
