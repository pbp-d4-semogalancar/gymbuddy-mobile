import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gymbuddy/models/exercise.dart';

class HowToService {
  static const String baseUrl = "http://127.0.0.1:8000/howto/api/list/";

  static Future<List<Exercise>> fetchExercises() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load exercises");
    }
  }
}
