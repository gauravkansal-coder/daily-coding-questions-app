import 'package:flutter/material.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';
import 'package:daily_coding_questions_app/ui/screens/home/problem_view.dart';

class BookmarksScreen extends StatefulWidget {
  final UserModel user;

  const BookmarksScreen({super.key, required this.user});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<List<Question>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _bookmarksFuture =
        FirestoreService().getQuestionsByIds(widget.user.bookmarkedQuestionIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Questions")),
      body: FutureBuilder<List<Question>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No saved questions yet."),
                ],
              ),
            );
          }

          final questions = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final question = questions[index];
              final isSolved =
                  widget.user.solvedQuestionIds.contains(question.id);

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      isSolved ? Colors.green.shade100 : Colors.orange.shade100,
                  child: Icon(
                    isSolved ? Icons.check : Icons.code,
                    color: isSolved ? Colors.green : Colors.orange,
                  ),
                ),
                title: Text(question.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${question.difficulty} • ${question.topic}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Problem View for Practice
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(question.title)),
                        body: ProblemView(
                          question: question,
                          isSolved: isSolved,
                          user: widget.user,
                          onSolve: () {
                            // Allow solving logic if you want them to practice old questions
                            FirestoreService().submitSolutionAndStreak(
                                widget.user.uid, question.id);
                            setState(() {}); // Refresh UI
                          },
                          onBookmark: (id) async {
                            await FirestoreService()
                                .toggleBookmark(widget.user.uid, id);
                            setState(() {
                              _loadBookmarks();
                            }); // Refresh list
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
