import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id; // This will be the date, e.g., "2026-01-18"
  final String title; // e.g., "Two Sum"
  final String description; // The full problem statement in Markdown
  final String difficulty; // "Easy", "Medium", or "Hard"
  final String topic; // e.g., "Arrays", "DP"
  final String starterCode; // e.g., "void main() { ... }"
  final String solution; // The hidden answer (Markdown)

  Question({
    required this.id,
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
      id: doc.id, // We use the document ID (the date) as our ID
      title: data['title'] ?? 'Untitled Question',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Medium',
      topic: data['topic'] ?? 'General',
      starterCode: data['starterCode'] ?? '',
      solution: data['solution'] ?? '',
    );
  }

  // -----------------------------------------------------------------------------
  // Method: Converts our Dart Object back to a Map (Useful for Admin/Uploading)
  // -----------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'topic': topic,
      'starterCode': starterCode,
      'solution': solution,
    };
  }
}
