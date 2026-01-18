import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/providers/auth_provider.dart';
import 'package:daily_coding_questions_app/providers/question_provider.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';
import 'package:daily_coding_questions_app/ui/screens/home/problem_view.dart'; // We will create this next

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final questionProv = Provider.of<QuestionProvider>(context, listen: false);

    // We need the User object to check if they already solved it
    // We can fetch the user details from the stream or just pass the UID if needed
    // For simplicity, we assume auth.user is ready.

    // In a real app, you might want to fetch the full UserModel here first
    // But for now, let's load the question. The provider handles the check.

    // Quick fetch of user model wrapper to pass to provider
    // (Ideally, AuthProvider should hold the UserModel, but let's keep it simple)
    final firestore = FirestoreService();
    if (auth.user != null) {
      // We listen to the user stream in the build method,
      // but for initial load, we might just fire the request.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final questionProv = Provider.of<QuestionProvider>(context);

    print('🏠 HomeScreen building...');
    print('   Auth user: ${auth.user?.email}');
    print('   Question provider - isLoading: ${questionProv.isLoading}, todayQuestion: ${questionProv.todayQuestion?.title}');

    // StreamBuilder checks for real-time Streak updates
    return StreamBuilder<UserModel>(
      stream: FirestoreService().getUserStream(auth.user!.uid),
      builder: (context, snapshot) {
        print('📊 StreamBuilder snapshot - hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('❌ Stream error: ${snapshot.error}');
        }
        
        // Once we have the user data, load the question logic *once*
        if (snapshot.hasData) {
          print('✅ User data received: ${snapshot.data?.email}');
          
          if (questionProv.todayQuestion == null && !questionProv.isLoading) {
            print('🚀 Loading question...');
            // Defer the load to next frame to avoid build conflicts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              questionProv.loadDailyQuestion(snapshot.data!);
            });
          } else {
            print('⏭️ Skipping load - todayQuestion: ${questionProv.todayQuestion?.title}, isLoading: ${questionProv.isLoading}');
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Waiting for user data...');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Daily Challenge"),
            actions: [
              // Streak Counter
              if (snapshot.hasData)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${snapshot.data!.currentStreak}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.signOut(),
              ),
            ],
          ),
          body: _buildBody(questionProv, snapshot.data),
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

    // Pass data to the specific Problem View
    return ProblemView(
      question: provider.todayQuestion!,
      isSolved: provider.isSolvedToday,
      onSolve: () => provider.submitAnswer(user!.uid),
    );
  }
}
