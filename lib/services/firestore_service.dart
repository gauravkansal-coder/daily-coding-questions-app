import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 1. Fetch Today's Question
  // ---------------------------------------------------------------------------
  Future<Question?> getTodaysQuestion() async {
    // Get today's date in "YYYY-MM-DD" format
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // We look for a document ID that matches today's date
      DocumentSnapshot doc =
          await _db.collection('questions').doc(todayDate).get();

      if (doc.exists) {
        return Question.fromFirestore(doc);
      } else {
        // If no question is found for today, return null (App should show "Rest Day")
        return null;
      }
    } catch (e) {
      print("Error fetching question: $e");
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Update User Streak (The Core Logic)
  // ---------------------------------------------------------------------------
  Future<void> submitSolutionAndStreak(String uid, String questionId) async {
    DocumentReference userRef = _db.collection('users').doc(uid);

    // Run as a Transaction to ensure data consistency
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return;

      UserModel user = UserModel.fromFirestore(snapshot);

      // If user already solved this specific question, stop here.
      if (user.solvedQuestionIds.contains(questionId)) return;

      // Calculate Dates
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String yesterday = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      int newStreak = user.currentStreak;

      // STREAK LOGIC:
      if (user.lastSolvedDate == yesterday) {
        // Solved yesterday? Increment streak.
        newStreak++;
      } else if (user.lastSolvedDate != today) {
        // Missed yesterday? Reset streak to 1.
        newStreak = 1;
      }
      // (If lastSolvedDate == today, we don't increment, just add the question ID)

      // Update Max Streak if needed
      int newLongest =
          (newStreak > user.longestStreak) ? newStreak : user.longestStreak;

      // Update Firestore
      transaction.update(userRef, {
        'currentStreak': newStreak,
        'longestStreak': newLongest,
        'lastSolvedDate': today,
        // Add questionId to the list of solved questions
        'solvedQuestionIds': FieldValue.arrayUnion([questionId]),
      });
    });
  }

  // ---------------------------------------------------------------------------
  // 3. Create/Get User Profile
  // ---------------------------------------------------------------------------
  Future<void> createUserIfNotExists(String uid, String email) async {
    DocumentReference userRef = _db.collection('users').doc(uid);
    DocumentSnapshot doc = await userRef.get();

    if (!doc.exists) {
      // Create new user profile with 0 streak
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        username: email.split('@')[0], // Default username from email
        currentStreak: 0,
        longestStreak: 0,
        lastSolvedDate: '',
        solvedQuestionIds: [],
      );
      await userRef.set(newUser.toMap());
    }
  }

  // Stream for real-time streak updates on the Home Screen
  Stream<UserModel> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => UserModel.fromFirestore(doc),
        );
  }
}
