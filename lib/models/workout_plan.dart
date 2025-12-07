class WorkoutPlan {
  final int id;
  final String exerciseName;
  final int sets;
  final int reps;
  final String planDate;

  WorkoutPlan({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.planDate,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      exerciseName: json['exercise_name'],
      sets: json['sets'],
      reps: json['reps'],
      planDate: json['plan_date'] ?? '',
    );
  }
}
