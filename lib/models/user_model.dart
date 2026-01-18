class User {
  final String uid;
  final String email;
  final String displayName;
  final int streak;
  final List<String> solvedQuestions;
  final DateTime lastActiveDate;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.streak = 0,
    this.solvedQuestions = const [],
    required this.lastActiveDate,
  });

  // Convert Firestore document to User object
  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      streak: data['streak'] as int? ?? 0,
      solvedQuestions: List<String>.from(
        data['solvedQuestions'] as List? ?? [],
      ),
      lastActiveDate: (data['lastActiveDate'] as DateTime?) ?? DateTime.now(),
    );
  }

  // Convert User object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'streak': streak,
      'solvedQuestions': solvedQuestions,
      'lastActiveDate': lastActiveDate,
    };
  }
}
