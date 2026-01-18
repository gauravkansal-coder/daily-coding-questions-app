import 'dart:convert'; // Required for JSON encoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // ---------------------------------------------------------------------------
  // Core Logic: Load Daily Question (Online First -> Then Offline)
  // ---------------------------------------------------------------------------
  Future<void> loadDailyQuestion(UserModel user) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try to fetch from Firestore (Internet required)
      _todayQuestion = await _firestoreService.getTodaysQuestion();

      if (_todayQuestion != null) {
        // SUCCESS: We found it online.
        // Save it to local storage so it works offline later today.
        await _cacheQuestion(_todayQuestion!);

        // Check if the user already solved this specific question
        _isSolvedToday = user.solvedQuestionIds.contains(_todayQuestion!.id);
      } else {
        // 2. Server returned null (maybe no doc for today), or connection flaky
        // Let's try to see if we have IT cached locally.
        await _loadFromCache();

        // If we found it in cache, we assume it's NOT solved yet
        // (syncing "solved" status strictly offline is complex, so we default to false)
        _isSolvedToday = false;
      }
    } catch (e) {
      print("⚠️ Network error, switching to Offline Mode: $e");
      // 3. Complete Network Failure -> Load from Cache
      await _loadFromCache();
      _isSolvedToday = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Helper: Save Question to Local Storage
  // ---------------------------------------------------------------------------
  Future<void> _cacheQuestion(Question q) async {
    final prefs = await SharedPreferences.getInstance();

    // Create a simple map to store as JSON
    Map<String, dynamic> questionMap = {
      'id': q.id,
      'date': q.date,
      'title': q.title,
      'description': q.description,
      'topic': q.topic,
      'difficulty': q.difficulty,
      'starterCode': q.starterCode,
      'solution': q.solution,
    };

    // Save the Question Data
    await prefs.setString('cached_question', jsonEncode(questionMap));
    // Save "Today's Date" so we know when this cache expires
    await prefs.setString(
        'cached_date', DateTime.now().toString().split(' ')[0]);
  }

  // ---------------------------------------------------------------------------
  // Helper: Load Question from Local Storage
  // ---------------------------------------------------------------------------
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    String? cachedDate = prefs.getString('cached_date');
    String today = DateTime.now().toString().split(' ')[0]; // "2026-01-18"

    // Only use the cache if it matches TODAY'S date.
    // We don't want to show yesterday's question.
    if (cachedDate == today && prefs.containsKey('cached_question')) {
      String? jsonStr = prefs.getString('cached_question');

      if (jsonStr != null) {
        Map<String, dynamic> data = jsonDecode(jsonStr);

        _todayQuestion = Question(
          id: data['id'],
          date: data['date'],
          title: data['title'],
          description: data['description'],
          topic: data['topic'],
          difficulty: data['difficulty'],
          starterCode: data['starterCode'],
          solution: data['solution'],
        );
        print("✅ Loaded question from Offline Cache");
      }
    } else {
      print("❌ Cache is outdated or empty.");
    }
  }

  // ---------------------------------------------------------------------------
  // Submit Answer Logic
  // ---------------------------------------------------------------------------
  Future<void> submitAnswer(String uid) async {
    if (_todayQuestion == null) return;

    try {
      // Update backend
      await _firestoreService.submitSolutionAndStreak(uid, _todayQuestion!.id);

      // Update local state immediately for UI feedback
      _isSolvedToday = true;
      notifyListeners();
    } catch (e) {
      print("Failed to submit (likely offline): $e");
      // Optional: You could show a SnackBar here saying "Saved locally"
      // but strictly speaking, we just let the UI stay "Unsolved" until they reconnect.
    }
  }

  // ---------------------------------------------------------------------------
  // Reset State (Logout)
  // ---------------------------------------------------------------------------
  void clearState() {
    _todayQuestion = null;
    _isLoading = false;
    _isSolvedToday = false;
    notifyListeners();
  }
}
