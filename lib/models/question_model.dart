class Question {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> tags;
  final String? solution;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tags,
    this.solution,
    required this.createdAt,
  });

  // Convert Firestore document to Question object
  factory Question.fromFirestore(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'Medium',
      tags: List<String>.from(data['tags'] as List? ?? []),
      solution: data['solution'] as String?,
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  // Convert Question object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'tags': tags,
      'solution': solution,
      'createdAt': createdAt,
    };
  }
}
