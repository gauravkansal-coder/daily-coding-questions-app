import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';

class ProblemView extends StatefulWidget {
  final Question question;
  final bool isSolved;
  final VoidCallback onSolve;
  final UserModel user;
  final Function(String) onBookmark;

  const ProblemView({
    super.key,
    required this.question,
    required this.isSolved,
    required this.onSolve,
    required this.user,
    required this.onBookmark,
  });

  @override
  State<ProblemView> createState() => _ProblemViewState();
}

class _ProblemViewState extends State<ProblemView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with starter code if available
    if (widget.question.starterCode.isNotEmpty) {
      _codeController.text = widget.question.starterCode;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBookmarked =
        widget.user.bookmarkedQuestionIds.contains(widget.question.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Difficulty, Topic, and Bookmark Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      widget.question.difficulty,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        _getDifficultyColor(widget.question.difficulty),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(widget.question.topic),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
              // BOOKMARK BUTTON
              IconButton(
                onPressed: () => widget.onBookmark(widget.question.id),
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber : Colors.grey,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Title
          Text(
            widget.question.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 3. Description (Markdown)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: MarkdownBody(data: widget.question.description),
          ),
          const SizedBox(height: 24),

          // 4. Input Area OR Solution View
          if (!widget.isSolved) ...[
            const Text(
              "Your Solution:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: "Type your code or logic here...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onSolve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit Answer"),
              ),
            ),
          ] else ...[
            // Success Message & Solution (This matches your screenshot fixes)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Answer Submitted! Solution Unlocked.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Official Solution:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MarkdownBody(data: widget.question.solution),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
