import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final int currentStreak;
  final int longestStreak;
  final String lastSolvedDate;
  final List<String> solvedQuestionIds;
  final List<String> bookmarkedQuestionIds; // <--- NEW FIELD

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastSolvedDate,
    required this.solvedQuestionIds,
    required this.bookmarkedQuestionIds, // <--- Add to constructor
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastSolvedDate: data['lastSolvedDate'] ?? '',
      solvedQuestionIds: List<String>.from(data['solvedQuestionIds'] ?? []),
      // Safely load the bookmarks list
      bookmarkedQuestionIds:
          List<String>.from(data['bookmarkedQuestionIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSolvedDate': lastSolvedDate,
      'solvedQuestionIds': solvedQuestionIds,
      'bookmarkedQuestionIds': bookmarkedQuestionIds, // <--- Save it back
    };
  }
}
