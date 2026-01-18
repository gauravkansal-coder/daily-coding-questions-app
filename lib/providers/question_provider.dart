import 'package:flutter/material.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';

class QuestionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Question? _todayQuestion;
  bool _isLoading = true;
  bool _isSolvedToday = false; // Tracks if user already finished today's task

  // Getters (So UI can read data but not change it directly)
  Question? get todayQuestion => _todayQuestion;
  bool get isLoading => _isLoading;
  bool get isSolvedToday => _isSolvedToday;

  // ---------------------------------------------------------------------------
  // 1. Load Data (Called when App Starts)
  // ---------------------------------------------------------------------------
  Future<void> loadDailyQuestion(UserModel? user) async {
    _isLoading = true;
    notifyListeners(); // Tells UI to show "Loading..."

    try {
      // Fetch Question
      _todayQuestion = await _firestoreService.getTodaysQuestion();

      // Check if user has already solved it
      if (_todayQuestion != null && user != null) {
        // We check if the Question ID (the Date) is in the user's solved list
        _isSolvedToday = user.solvedQuestionIds.contains(_todayQuestion!.id);
      }
    } catch (e) {
      print("Error loading question: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Tells UI to show the content
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Submit Answer
  // ---------------------------------------------------------------------------
  Future<void> submitAnswer(String uid) async {
    if (_todayQuestion == null) return;

    // 1. Update backend (Streak + Solved List)
    await _firestoreService.submitSolutionAndStreak(uid, _todayQuestion!.id);

    // 2. Update local state immediately so UI updates (Green Checkmark)
    _isSolvedToday = true;
    notifyListeners();
  }
}
