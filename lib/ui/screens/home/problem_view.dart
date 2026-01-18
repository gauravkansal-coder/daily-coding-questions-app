import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:daily_coding_questions_app/models/question_model.dart';

class ProblemView extends StatefulWidget {
  final Question question;
  final bool isSolved;
  final VoidCallback onSolve;

  const ProblemView({
    super.key,
    required this.question,
    required this.isSolved,
    required this.onSolve,
  });

  @override
  State<ProblemView> createState() => _ProblemViewState();
}

class _ProblemViewState extends State<ProblemView> {
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text area with starter code
    _codeController = TextEditingController(text: widget.question.starterCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Helper to pick color based on difficulty
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------
          // 1. Header (Title + Badges)
          // -------------------------------------------------------
          Text(
            widget.question.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
          const Divider(height: 32),

          // -------------------------------------------------------
          // 2. Question Description (Markdown)
          // -------------------------------------------------------
          const Text(
            "Problem Description",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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

          // -------------------------------------------------------
          // 3. The "Switch": Input vs Solution
          // -------------------------------------------------------
          if (widget.isSolved) ...[
            // STATE: SOLVED -> Show Solution
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Great Job! You solved it.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Official Solution:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  MarkdownBody(data: widget.question.solution),
                ],
              ),
            ),
          ] else ...[
            // STATE: UNSOLVED -> Show Input
            const Text(
              "Your Solution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              maxLines: 10,
              style: const TextStyle(
                  fontFamily: 'Courier', fontSize: 14), // Monospace font
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your code or logic here...",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (_codeController.text.trim().isNotEmpty) {
                  widget.onSolve(); // Trigger the Provider logic
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please write some code first!")),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text("SUBMIT SOLUTION"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
