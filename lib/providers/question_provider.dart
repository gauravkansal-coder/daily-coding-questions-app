import 'package:flutter/material.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';

class QuestionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Question? _todayQuestion;
  bool _isLoading = false;
  bool _isSolvedToday = false;

  Question? get todayQuestion => _todayQuestion;
  bool get isLoading => _isLoading;
  bool get isSolvedToday => _isSolvedToday;

  // Load Data
  Future<void> loadDailyQuestion(UserModel user) async {
    // Prevent double loading
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _todayQuestion = await _firestoreService.getTodaysQuestion();

      if (_todayQuestion != null) {
        // Check if the user already solved this specific question ID
        _isSolvedToday = user.solvedQuestionIds.contains(_todayQuestion!.id);
      } else {
        // No question found for today
        _isSolvedToday = false;
      }
    } catch (e) {
      print("Error loading question: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit Answer
  Future<void> submitAnswer(String uid) async {
    if (_todayQuestion == null) return;

    // Update backend
    await _firestoreService.submitSolutionAndStreak(uid, _todayQuestion!.id);

    // Update local state immediately for UI feedback
    _isSolvedToday = true;
    notifyListeners();
  }

  // CRITICAL FIX: Reset everything when logging out
  void clearState() {
    _todayQuestion = null;
    _isLoading = false;
    _isSolvedToday = false;
    notifyListeners();
  }
}
