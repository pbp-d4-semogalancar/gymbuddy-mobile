import 'dart:convert';

UserProfileEntry userProfileEntryFromJson(String str) => UserProfileEntry.fromJson(json.decode(str));

String userProfileEntryToJson(UserProfileEntry data) => json.encode(data.toJson());

class UserProfileEntry {
  int id;
  String username;
  String displayName;
  String bio;
  String? profilePicture;
  List<FavoriteWorkout> favoriteWorkouts;

  UserProfileEntry({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    this.profilePicture,
    required this.favoriteWorkouts,
  });

  factory UserProfileEntry.fromJson(Map<String, dynamic> json) => UserProfileEntry(
    id: json["id"],
    username: json["username"],
    displayName: json["display_name"],
    bio: json["bio"],
    profilePicture: json["profile_picture"] as String?,
    favoriteWorkouts: List<FavoriteWorkout>.from(json["favorite_workouts"].map((x) => FavoriteWorkout.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "display_name": displayName,
    "bio": bio,
    "profile_picture": profilePicture,
    "favorite_workouts": List<dynamic>.from(favoriteWorkouts.map((x) => x.toJson())),
  };
}

class FavoriteWorkout {
  int id;
  String exerciseName;

  FavoriteWorkout({
    required this.id,
    required this.exerciseName,
  });

  factory FavoriteWorkout.fromJson(Map<String, dynamic> json) => FavoriteWorkout(
    id: json["id"],
    exerciseName: json["exercise_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "exercise_name": exerciseName,
  };
}