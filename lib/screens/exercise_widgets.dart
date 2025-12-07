import 'package:flutter/material.dart';
import 'package:gymbuddy/models/exercise.dart';

/// ===============================================
///              EXERCISE CARD UI
/// ===============================================
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ICON / IMAGE
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center, size: 40, color: Colors.blue),
              ),

              const SizedBox(width: 16),

              // TEXT INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),
                    
                    // Muscle Badge
                    Row(
                      children: [
                        Chip(
                          backgroundColor: Colors.red.shade100,
                          label: Text(
                            exercise.mainMuscle,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Equipment Badge
                        Chip(
                          backgroundColor: Colors.green.shade100,
                          label: Text(
                            exercise.equipment?.isEmpty ?? true 
                              ? "Bodyweight"
                              : exercise.equipment!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================================
///              DETAIL PAGE UI
/// ===============================================
class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.exerciseName),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // HEADER SECTION
            Row(
              children: [
                Icon(Icons.fitness_center,
                    size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BADGES
            Row(
              children: [
                Chip(
                  backgroundColor: Colors.red.shade100,
                  label: Text(exercise.mainMuscle),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: Colors.green.shade100,
                  label: Text(
                    exercise.equipment?.isEmpty ?? true
                        ? "Bodyweight"
                        : exercise.equipment!,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INSTRUCTIONS
            const Text(
              "Instructions",
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  exercise.instructions ?? "No instructions available.",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
