class Exercise {
  final int id;
  final String exerciseName;
  final String mainMuscle;
  final String equipment;
  final String instructions;

  Exercise({
    required this.id,
    required this.exerciseName,
    required this.mainMuscle,
    required this.equipment,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      exerciseName: json['exercise_name'],
      mainMuscle: json['main_muscle'],
      equipment: json['equipment'] ?? "",
      instructions: json['instructions'] ?? "",
    );
  }
}
