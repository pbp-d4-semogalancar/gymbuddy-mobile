import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gymbuddy/models/exercise.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HowToService {
  static const String baseUrl = "http://127.0.0.1:8000/howto/api/list/";
  static const String optionsUrl = "http://127.0.0.1:8000/howto/api/options/";  

  // GET list exercise
  static Future<List<Exercise>> fetchExercises({String? muscle, String? equipment}) async {
    Uri url = Uri.parse(baseUrl);

    // Tambah query parameter
    if (muscle != null || equipment != null) {
      url = Uri.parse(
          "$baseUrl?muscle=${muscle ?? ''}&equipment=${equipment ?? ''}");
    }

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load exercise");
    }

    List data = jsonDecode(response.body);
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  // NEW → GET unique muscle & equipment
  static Future<Map<String, List<String>>> fetchOptions() async {
    final response = await http.get(Uri.parse(optionsUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to load filter options");
    }

    final data = jsonDecode(response.body);

    return {
      "muscles": List<String>.from(data["muscles"]),
      "equipments": List<String>.from(data["equipments"]),
    };
  }
}
