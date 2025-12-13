import 'package:flutter/material.dart';
import 'package:gymbuddy/models/exercise.dart';

class HowtoExerciseCard extends StatelessWidget {
  final Exercise ex;

  const HowtoExerciseCard({super.key, required this.ex});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ex.exerciseName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text("Muscle: ${ex.mainMuscle}"),
              Text("Equipment: ${ex.equipment ?? '-'}"),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ex.exerciseName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Muscle: ${ex.mainMuscle}"),
              Text("Equipment: ${ex.equipment ?? '-'}"),
              const SizedBox(height: 12),
              const Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(ex.instructions ?? "No instructions"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
