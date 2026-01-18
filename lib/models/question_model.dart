import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id; // This is the Document ID (e.g., "2026-01-18")
  final String date; // <--- NEW FIELD: Explicit date for offline checks
  final String title;
  final String description;
  final String difficulty;
  final String topic;
  final String starterCode;
  final String solution;

  Question({
    required this.id,
    required this.date, // <--- Added to constructor
    required this.title,
    required this.description,
    required this.difficulty,
    required this.topic,
    required this.starterCode,
    required this.solution,
  });

  // -----------------------------------------------------------------------------
  // Factory Constructor: Converts a Firebase Document into a Dart Object
  // -----------------------------------------------------------------------------
  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      date: doc.id, // <--- CRITICAL: We use the Doc ID as the 'date' property
      title: data['title'] ?? 'Untitled Question',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Medium',
      topic: data['topic'] ?? 'General',
      starterCode: data['starterCode'] ?? '',
      solution: data['solution'] ?? '',
    );
  }

  // -----------------------------------------------------------------------------
  // Method: Converts our Dart Object back to a Map
  // -----------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'topic': topic,
      'starterCode': starterCode,
      'solution': solution,
      // We don't necessarily need to save 'date' or 'id' back to Firestore
      // because they are used as the Document Key itself.
    };
  }
}
