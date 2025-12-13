import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gymbuddy/models/exercise.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class HowToService {
  static const String apiBase = "http://localhost:8000/howto/api";

  static Future<List<Exercise>> fetchExercises({String? muscle, String? equipment}) async {
    final uri = Uri.parse("$apiBase/list/").replace(
      queryParameters: {
        if (muscle != null && muscle.isNotEmpty) "muscle": muscle,
        if (equipment != null && equipment.isNotEmpty) "equipment": equipment,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed: ${response.statusCode} ${response.body}");
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((e) => Exercise.fromJson(e)).toList();
  }

  static Future<Map<String, List<String>>> fetchOptions() async {
    final response = await http.get(Uri.parse("$apiBase/options/"));
    if (response.statusCode != 200) {
      throw Exception("Options failed: ${response.statusCode} ${response.body}");
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    return {
      "muscles": List<String>.from(data["muscles"] ?? []),
      "equipments": List<String>.from(data["equipments"] ?? []),
    };
  }

  // ===== FAVORITES (per akun) =====
  static Future<Set<int>> fetchFavoriteIds(CookieRequest request) async {
    final res = await request.get("$apiBase/favorites/");
    if (res is Map && res["ids"] is List) {
      return Set<int>.from((res["ids"] as List).map((e) => e as int));
    }
    throw Exception("Invalid favorites response: $res");
  }

  static Future<bool> toggleFavorite(CookieRequest request, int exerciseId) async {
    final res = await request.postJson(
      "$apiBase/favorites/toggle/$exerciseId/",
      jsonEncode({}),
    );
    if (res is Map && res.containsKey("bookmarked")) {
      return res["bookmarked"] == true;
    }
    throw Exception("Invalid toggle response: $res");
  }
}
