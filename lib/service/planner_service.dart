import 'dart:convert';
import 'package:http/http.dart' as http;

class PlannerService {
  // Ganti URL ini dengan URL backend Django Anda (untuk emulator Android gunakan 10.0.2.2)
  final String baseUrl = "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id";

  Future<Map<String, dynamic>> fetchWorkoutLogs(
    int year,
    int month, {
    String? weekStart,
  }) async {
    // Backend perlu endpoint baru yang mengembalikan JSON lengkap (plans + statistik)
    // Anggap endpointnya: /planner/api/get-logs/?year=2025&month=10&week_start=...

    var url = Uri.parse(
      '$baseUrl/planner/api/get-logs/?year=$year&month=$month${weekStart != null && weekStart.isNotEmpty ? "&week_start_date=$weekStart" : ""}',
    );

    // Jangan lupa sertakan Cookie/Session jika perlu autentikasi
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['plans'] != null) {
        for (var plan in data['plans']) {
          plan['sets'] = plan['sets'] ?? 0;
          plan['reps'] = plan['reps'] ?? 0;
        }
      }
      return data;
    } else {
      throw Exception('Gagal memuat log latihan');
    }
  }

  Future<bool> completeLog(int planId, String description) async {
    // BENAR (Ini URL API yang aman untuk Mobile):
    var url = Uri.parse('$baseUrl/planner/api/log/complete/$planId/');

    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        // Sertakan Cookie di sini
      },
      body: {"description": description},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> searchExercises(String query) async {
    // Gunakan 10.0.2.2 untuk emulator Android, localhost untuk iOS/Web
    // Pastikan URL endpoint backend sudah benar
    var url = Uri.parse('$baseUrl/planner/search-exercises/?q=$query');

    try {
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Backend mengembalikan {'exercises':List}, jadi kita ambil key 'exercises'
        return data['exercises'];
      } else {
        print("Error search: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception search: $e");
      return [];
    }
  }
}
