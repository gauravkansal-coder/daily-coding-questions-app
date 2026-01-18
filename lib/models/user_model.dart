import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final int currentStreak;
  final int longestStreak;
  final String lastSolvedDate; // Stores the date as "YYYY-MM-DD"
  final List<String> solvedQuestionIds; // Keeps track of which days are done

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastSolvedDate,
    required this.solvedQuestionIds,
  });

  // -----------------------------------------------------------------------------
  // Factory Constructor: Firestore Document -> Dart Object
  // -----------------------------------------------------------------------------
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? 'Coder',
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastSolvedDate: data['lastSolvedDate'] ?? '',
      // Firestore stores lists as List<dynamic>, so we must cast it to List<String>
      solvedQuestionIds: List<String>.from(data['solvedQuestionIds'] ?? []),
    );
  }

  // -----------------------------------------------------------------------------
  // Method: Dart Object -> Map (Used when Registering a new user)
  // -----------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSolvedDate': lastSolvedDate,
      'solvedQuestionIds': solvedQuestionIds,
    };
  }
}
