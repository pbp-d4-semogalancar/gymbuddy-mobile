import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_plan.dart';

class PlannerService {
  // Ganti URL ini dengan URL backend Django Anda (untuk emulator Android gunakan 10.0.2.2)
  final String baseUrl = "http://127.0.0.1:8000";

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
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat log latihan');
    }
  }

  Future<bool> completeLog(int planId, String description) async {
    var url = Uri.parse('$baseUrl/planner/log/complete/$planId/');

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
}
