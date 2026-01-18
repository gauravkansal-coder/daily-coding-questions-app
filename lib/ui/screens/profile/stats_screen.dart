import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_coding_questions_app/models/user_model.dart';
import 'package:daily_coding_questions_app/ui/screens/home/bookmarks_screen.dart'; // Make sure to import this

class StatsScreen extends StatelessWidget {
  final UserModel user;

  const StatsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Progress")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            const Text(
              "Streak Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 2. Big Stat Cards
            Row(
              children: [
                _buildStatCard(
                  title: "Current Streak",
                  value: "${user.currentStreak} 🔥",
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: "Longest Streak",
                  value: "${user.longestStreak} 🏆",
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              title: "Total Problems Solved",
              value: "${user.solvedQuestionIds.length} ✅",
              color: Colors.green,
              isFullWidth: true,
            ),

            const SizedBox(height: 16),

            // 3. Saved Questions Button (NEW)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookmarksScreen(user: user),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark),
                label: const Text("View Saved Questions"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Consistency Visual (Last 7 Days)
            const Text(
              "Last 7 Days Consistency",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  // Logic: Calculate date for this index (6 days ago -> Today)
                  DateTime date =
                      DateTime.now().subtract(Duration(days: 6 - index));
                  String dateId = DateFormat('yyyy-MM-dd').format(date);
                  String dayName =
                      DateFormat('E').format(date)[0]; // M, T, W...

                  bool isSolved = user.solvedQuestionIds.contains(dateId);
                  bool isToday = index == 6;

                  return Column(
                    children: [
                      Text(dayName,
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSolved
                              ? Colors.green
                              : (isToday
                                  ? Colors.grey.shade200
                                  : Colors.red.shade50),
                          shape: BoxShape.circle,
                          border: isToday && !isSolved
                              ? Border.all(color: Colors.orange, width: 2)
                              : null,
                        ),
                        child: Icon(
                          isSolved ? Icons.check : Icons.close,
                          size: 16,
                          color: isSolved ? Colors.white : Colors.red.shade200,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Expanded(
      flex: isFullWidth ? 0 : 1,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
