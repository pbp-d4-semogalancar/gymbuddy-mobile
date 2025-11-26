class Exercise {
  final int id;
  final String exerciseName;
  final String mainMuscle;
  final String equipment;
  final String instructions;
  final String? image;

  Exercise({
    required this.id,
    required this.exerciseName,
    required this.mainMuscle,
    required this.equipment,
    required this.instructions,
    this.image,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      exerciseName: json['exercise_name'],
      mainMuscle: json['main_muscle'],
      equipment: json['equipment'] ?? "",
      instructions: json['instructions'] ?? "",
      image: json['image'],
    );
  }
}
