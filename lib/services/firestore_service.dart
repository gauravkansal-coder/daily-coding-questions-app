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
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot doc =
          await _db.collection('questions').doc(todayDate).get();
      if (doc.exists) {
        return Question.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      // In production, use a logging service instead of print
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Update User Streak (Transaction Safe)
  // ---------------------------------------------------------------------------
  Future<void> submitSolutionAndStreak(String uid, String questionId) async {
    DocumentReference userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      UserModel user = UserModel.fromFirestore(snapshot);

      if (user.solvedQuestionIds.contains(questionId)) return;

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String yesterday = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      int newStreak = user.currentStreak;

      if (user.lastSolvedDate == yesterday) {
        newStreak++;
      } else if (user.lastSolvedDate != today) {
        newStreak = 1;
      }

      int newLongest =
          (newStreak > user.longestStreak) ? newStreak : user.longestStreak;

      transaction.update(userRef, {
        'currentStreak': newStreak,
        'longestStreak': newLongest,
        'lastSolvedDate': today,
        'solvedQuestionIds': FieldValue.arrayUnion([questionId]),
      });
    });
  }

  // ---------------------------------------------------------------------------
  // 3. Create User Profile
  // ---------------------------------------------------------------------------
  Future<void> createUserIfNotExists(String uid, String email) async {
    DocumentReference userRef = _db.collection('users').doc(uid);
    DocumentSnapshot doc = await userRef.get();

    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        username: email.split('@')[0],
        currentStreak: 0,
        longestStreak: 0,
        lastSolvedDate: '',
        solvedQuestionIds: [],
        bookmarkedQuestionIds: [],
      );
      await userRef.set(newUser.toMap());
    }
  }

  Stream<UserModel> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => UserModel.fromFirestore(doc),
        );
  }

  // ---------------------------------------------------------------------------
  // 4. Toggle Bookmark (Add/Remove)
  // ---------------------------------------------------------------------------
  Future<void> toggleBookmark(String uid, String questionId) async {
    DocumentReference userRef = _db.collection('users').doc(uid);
    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      UserModel user = UserModel.fromFirestore(doc);

      if (user.bookmarkedQuestionIds.contains(questionId)) {
        await userRef.update({
          'bookmarkedQuestionIds': FieldValue.arrayRemove([questionId])
        });
      } else {
        await userRef.update({
          'bookmarkedQuestionIds': FieldValue.arrayUnion([questionId])
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Fetch Multiple Questions by ID (For Bookmarks Screen)
  // ---------------------------------------------------------------------------
  Future<List<Question>> getQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      // Parallel fetch for better performance
      List<DocumentSnapshot> snapshots = await Future.wait(
        ids.map((id) => _db.collection('questions').doc(id).get()),
      );

      return snapshots
          .where((doc) => doc.exists)
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
