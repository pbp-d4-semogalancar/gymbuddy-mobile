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
  String? description; // Baru
  bool isCompleted; // Baru
  DateTime? completedAt; // Baru

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

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: json["id"],
    userId: json["user"],
    exerciseId: json["exercise_id"] ?? 0, // Sesuaikan key dari JSON backend
    exerciseName:
        json["exercise_name"] ??
        "Latihan", // Backend harus kirim ini atau kita fetch terpisah
    sets: json["sets"],
    reps: json["reps"],
    planDate: DateTime.parse(json["plan_date"]),
    description: json["description"],
    isCompleted: json["is_completed"] ?? false,
    completedAt: json["completed_at"] != null
        ? DateTime.parse(json["completed_at"])
        : null,
  );

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
