import 'dart:convert';

List<WorkoutPlan> workoutPlanFromJson(String str) => List<WorkoutPlan>.from(
  json.decode(str).map((x) => WorkoutPlan.fromJson(x)),
);

String workoutPlanToJson(List<WorkoutPlan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WorkoutPlan {
  int id;
  int userId;
  int exerciseId;
  String exerciseName;
  int sets;
  int reps;
  DateTime planDate;
  String? description;
  bool isCompleted;
  DateTime? completedAt;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.planDate,
    this.description,
    required this.isCompleted,
    this.completedAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      // [FIX] Gunakan (json['key'] is int) ? value : 0
      // Ini mencegah crash jika value-nya null atau string
      id: json["id"] is int ? json["id"] : 0,
      userId: json["user"] is int ? json["user"] : 0,
      exerciseId: json["exercise_id"] is int ? json["exercise_id"] : 0,
      exerciseName: json["exercise_name"]?.toString() ?? "Latihan",
      sets: json["sets"] is int ? json["sets"] : 0,
      reps: json["reps"] is int ? json["reps"] : 0,
      planDate:
          DateTime.tryParse(json["plan_date"].toString()) ?? DateTime.now(),
      description: json["description"]?.toString(),
      isCompleted: json["is_completed"] ?? false,
      completedAt: json["completed_at"] != null
          ? DateTime.tryParse(json["completed_at"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": userId,
    "exercise_id": exerciseId,
    "sets": sets,
    "reps": reps,
    "plan_date":
        "${planDate.year.toString().padLeft(4, '0')}-${planDate.month.toString().padLeft(2, '0')}-${planDate.day.toString().padLeft(2, '0')}",
    "description": description,
    "is_completed": isCompleted,
    "completed_at": completedAt?.toIso8601String(),
  };
}
