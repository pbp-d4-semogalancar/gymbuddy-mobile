import 'dart:convert';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WorkoutLogPage extends StatefulWidget {
  const WorkoutLogPage({super.key});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends State<WorkoutLogPage> {
  // Inputs
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  // Exercise Selection
  int? selectedExerciseId;

  // Date Selection
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = _numToMonth(DateTime.now().month);
  String selectedDay = DateTime.now().day.toString().padLeft(2, '0');

  // Backend URL
  final String domain = "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id";

  // --- Helper Functions ---
  String _monthToNum(String month) {
    switch (month) {
      case "January":
        return "01";
      case "February":
        return "02";
      case "March":
        return "03";
      case "April":
        return "04";
      case "May":
        return "05";
      case "June":
        return "06";
      case "July":
        return "07";
      case "August":
        return "08";
      case "September":
        return "09";
      case "October":
        return "10";
      case "November":
        return "11";
      case "December":
        return "12";
      default:
        return "01";
    }
  }

  static String _numToMonth(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  // --- API Functions (Tetap sama, menggunakan CookieRequest) ---
  Future<List<WorkoutPlan>> fetchPlans(CookieRequest request) async {
    String dateString =
        "$selectedYear-${_monthToNum(selectedMonth)}-$selectedDay";
    final url = '$domain/planner/api/get-plans-for-date/?date=$dateString';
    try {
      final response = await request.get(url);
      if (response != null && response['plans'] != null) {
        final List<dynamic> plansJson = response['plans'];
        return plansJson.map((json) => WorkoutPlan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Exception fetching plans: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchExercises(
    String query,
    CookieRequest request,
  ) async {
    if (query.length < 2) return [];
    try {
      final url = '$domain/planner/search-exercises/?q=$query';
      final response = await request.get(url);
      if (response != null && response['exercises'] != null) {
        return List<Map<String, dynamic>>.from(
          (response['exercises'] as List).map(
            (item) => item as Map<String, dynamic>,
          ),
        );
      }
      return [];
    } catch (e) {
      debugPrint("Search Exception: $e");
      return [];
    }
  }

  Future<void> addPlan(CookieRequest request) async {
    if (selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an exercise from the list"),
        ),
      );
      return;
    }
    final url = '$domain/planner/api/add-plan/';
    String dateString =
        "$selectedYear-${_monthToNum(selectedMonth)}-$selectedDay";
    try {
      final response = await request.postJson(
        url,
        jsonEncode({
          "exercise_id": selectedExerciseId,
          "sets": int.tryParse(_setsController.text) ?? 0,
          "reps": int.tryParse(_repsController.text) ?? 0,
          "plan_date": dateString,
        }),
      );
      if (response['id'] != null || response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout Added Successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response['error'] ?? 'Unknown error'}"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error adding plan: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- UI HEADER BARU (Gaya Homepage) ---
  Widget _buildHeaderBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: SizedBox(
        width: double.infinity,
        height: 200, // Tinggi disesuaikan
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image Blurred
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                "lib/Assets/Background.jpg", // Aset yang sama dengan homepage
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) =>
                    Container(color: Colors.grey.shade800),
              ),
            ),
            // 2. Overlay Hitam Transparan
            Container(color: Colors.black.withOpacity(0.5)),
            // 3. Konten Header
            Stack(
              children: [
                // Tombol Kembali (Warna Putih agar kontras dengan background gelap)
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Judul Halaman
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "Add Your Workout Activities Here!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        // Tambah shadow agar lebih terbaca
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    int daysInMonth = DateTime(
      int.parse(selectedYear),
      int.parse(_monthToNum(selectedMonth)) + 1,
      0,
    ).day;

    List<String> days = List.generate(
      daysInMonth,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );

    if (int.parse(selectedDay) > daysInMonth) {
      selectedDay = daysInMonth.toString().padLeft(2, '0');
    }

    return Scaffold(
      // Menggunakan SafeArea untuk konten di bawah header
      body: Column(
        children: [
          _buildHeaderBanner(), // Header Baru
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Date Pickers ---
                    const Text(
                      "Planned Date:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDropdown(
                            "Year",
                            ["2024", "2025", "2026"],
                            selectedYear,
                            (v) => setState(() => selectedYear = v!),
                          ),
                          const SizedBox(width: 10),
                          _buildDropdown(
                            "Month",
                            [
                              "January",
                              "February",
                              "March",
                              "April",
                              "May",
                              "June",
                              "July",
                              "August",
                              "September",
                              "October",
                              "November",
                              "December",
                            ],
                            selectedMonth,
                            (v) => setState(() => selectedMonth = v!),
                          ),
                          const SizedBox(width: 10),
                          _buildDropdown(
                            "Date",
                            days,
                            days.contains(selectedDay) ? selectedDay : days[0],
                            (v) => setState(() => selectedDay = v!),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Exercise Input ---
                    const Text(
                      "1. Cari Latihan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (textEditingValue) =>
                          searchExercises(textEditingValue.text, request),
                      displayStringForOption: (option) => option['name'],
                      onSelected: (selection) {
                        setState(() => selectedExerciseId = selection['id']);
                        FocusScope.of(context).unfocus();
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                hintText: "e.g. Bench Press",
                                border: const UnderlineInputBorder(),
                                // Ikon Search jadi Hitam
                                suffixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                              cursorColor: Colors.black, // Kursor Hitam
                            );
                          },
                    ),

                    const SizedBox(height: 20),

                    // --- Sets & Reps Inputs ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            "2. Sets",
                            "cth: 3",
                            _setsController,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildNumberInput(
                            "3. Reps",
                            "cth: 10",
                            _repsController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- Add Planner Button (Warna Hitam) ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // Warna Latar Belakang Hitam
                          backgroundColor: Colors.black,
                          // Warna Teks Putih
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        onPressed: () => addPlan(request),
                        child: const Text(
                          "Tambahkan ke Rencana",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Log Activities List ---
                    const Text(
                      "Rencana Latihan Tanggal Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.black12),

                    FutureBuilder<List<WorkoutPlan>>(
                      future: fetchPlans(request),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(
                              child: Text(
                                "Belum ada rencana latihan pada tanggal ini.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final plan = snapshot.data![index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black12,
                                    // Ikon Dumbbell jadi Hitam
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: Colors.black,
                                    ),
                                  ),
                                  title: Text(
                                    plan.exerciseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${plan.sets} set x ${plan.reps} reps",
                                  ),
                                  // Ikon Status jadi Hitam/Abu Gelap
                                  trailing: plan.isCompleted
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.black,
                                        )
                                      : const Icon(
                                          Icons.circle_outlined,
                                          color: Colors.black54,
                                        ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildNumberInput(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          cursorColor: Colors.black, // Kursor Hitam
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.black,
              ), // Border Fokus Hitam
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String currentVal,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: items.contains(currentVal) ? currentVal : items[0],
            underline: Container(),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ), // Ikon Panah Hitam
            items: items
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
