import 'package:flutter/material.dart';

/// Streak history & analytics
class StatsScreen extends StatefulWidget {
  final String userId;

  const StatsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    // TODO: Load user statistics from provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TODO: Add streak display
            // TODO: Add total solved count
            // TODO: Add difficulty distribution chart
            // TODO: Add solved questions list
            // TODO: Add calendar heatmap (optional)
          ],
        ),
      ),
    );
  }
}
