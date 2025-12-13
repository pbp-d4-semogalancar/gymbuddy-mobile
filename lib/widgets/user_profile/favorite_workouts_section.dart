import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';

class FavoriteWorkoutsSection extends StatelessWidget {
  final List<FavoriteWorkout> workouts;
  final bool isOwner;
  final bool hasChanges;
  final VoidCallback onAdd;
  final Function(int id) onRemove;

  const FavoriteWorkoutsSection({
    super.key,
    required this.workouts,
    required this.isOwner,
    required this.hasChanges,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...workouts.map(
              (w) => Chip(
            label: Text(w.exerciseName),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            onDeleted: isOwner && hasChanges ? () => onRemove(w.id) : null,
          ),
        ),
        if (isOwner)
          ActionChip(
            label: const Icon(Icons.add, size: 20, color: Colors.white),
            backgroundColor: Color(0xFF4A4A4A),
            onPressed: onAdd,
          ),
      ],
    );
  }
}