import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gymbuddy/models/exercise.dart';

class HowToService {
  static const String baseUrl = "http://127.0.0.1:8000/howto/api/list/";
  static const String optionsUrl = "http://127.0.0.1:8000/howto/api/options/";  

  static Future<List<Exercise>> fetchExercises({String? muscle, String? equipment}) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      if (muscle != null) "muscle": muscle,
      if (equipment != null) "equipment": equipment,
    });

    final response = await http.get(uri);
    final List data = jsonDecode(response.body);
    return data.map((e) => Exercise.fromJson(e)).toList();
  }

  // NEW — ambil unique muscles & equipment
  static Future<Map<String, List<String>>> fetchOptions() async {
    final response = await http.get(Uri.parse(optionsUrl));
    final Map<String, dynamic> data = jsonDecode(response.body);

    return {
      "muscles": List<String>.from(data["muscles"]),
      "equipments": List<String>.from(data["equipments"]),
    };
  }
}
