import 'dart:convert';

List<Target> targetFromJson(String str) =>
    List<Target>.from(json.decode(str).map((x) => Target.fromJson(x)));

String targetToJson(List<Target> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Target {
  int pk;
  Fields fields;

  Target({required this.pk, required this.fields});

  factory Target.fromJson(Map<String, dynamic> json) =>
      Target(pk: json["pk"], fields: Fields.fromJson(json["fields"]));

  Map<String, dynamic> toJson() => {"pk": pk, "fields": fields.toJson()};
}

class Fields {
  String title;
  String description;
  String status; // Asumsi backend mengirim "Finished" / "Unfinished"
  DateTime dueDate;
  int user;

  Fields({
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.user,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    title: json["title"],
    description: json["description"],
    status: json["status"],
    dueDate: DateTime.parse(
      json["due_date"],
    ), // Pastikan field di Django models.py adalah 'due_date'
    user: json["user"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "status": status,
    "due_date":
        "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
    "user": user,
  };
}
