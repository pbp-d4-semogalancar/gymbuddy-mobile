import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // Kita perlu menyimpan ID latihan yang dipilih untuk dikirim ke Django
  int? selectedExerciseId;
  String? selectedExerciseName; // Opsional: untuk UI feedback

  // Date Selection (Default ke Hari Ini)
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = _numToMonth(DateTime.now().month);
  String selectedDay = DateTime.now().day.toString().padLeft(2, '0');

  // Backend URL (Gunakan 10.0.2.2 untuk Android Emulator, atau localhost untuk iOS/Web)
  final String domain = kIsWeb
      ? "http://127.0.0.1:8000" // Jika dijalankan di Chrome/Web
      : "http://10.0.2.2:8000"; // Jika dijalankan di Android Emulator

  // --- Helper Functions ---

  // Convert Month Name to Number string "01", "12" for the Backend Date
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

  // Convert Number to Month Name for the UI
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

  // --- API 1: Fetch Plans for the List ---
  Future<List<WorkoutPlan>> fetchPlans() async {
    String dateString =
        "$selectedYear-${_monthToNum(selectedMonth)}-$selectedDay";
    final url = Uri.parse(
      '$domain/planner/api/get-plans-for-date/?date=$dateString',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> plansJson = data['plans'] ?? [];
        return plansJson.map((json) => WorkoutPlan.fromJson(json)).toList();
      } else {
        print("Fetch Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception fetching plans: $e");
      return [];
    }
  }

  // --- API 2: Search Exercises (Autocomplete) ---
  // Calls your ExerciseSearchJSONView
  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    if (query.length < 2) return [];

    try {
      final url = Uri.parse(
        '$domain/planner/search-exercises/',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(
          (data['exercises'] as List).map(
            (item) => item as Map<String, dynamic>,
          ),
        );
      } else {
        print("Search API Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Search Exception: $e");
      // Kembalikan list kosong jika error agar UI tidak crash
      return [];
    }
  }

  // --- API 3: Add New Plan ---
  Future<void> addPlan() async {
    if (selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an exercise from the list"),
        ),
      );
      return;
    }

    final url = Uri.parse('$domain/planner/api/add-plan/');
    String dateString =
        "$selectedYear-${_monthToNum(selectedMonth)}-$selectedDay";

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // Jika backend butuh auth, tambahkan cookie/token di sini
        },
        body: json.encode({
          "exercise_id": selectedExerciseId,
          "sets": int.tryParse(_setsController.text) ?? 0,
          "reps": int.tryParse(_repsController.text) ?? 0,
          "plan_date": dateString,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _setsController.clear();
          _repsController.clear();
          selectedExerciseId = null; // Reset selection
          selectedExerciseName = null;
        });
        // Force refresh UI (FutureBuilder akan terpanggil ulang karena setState)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout Added Successfully!")),
        );
      } else {
        print("Add Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add workout: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error adding plan: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate valid days for the dropdown based on the selected month/year
    int daysInMonth = DateTime(
      int.parse(selectedYear),
      int.parse(_monthToNum(selectedMonth)) + 1,
      0,
    ).day;

    List<String> days = List.generate(
      daysInMonth,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );

    // Reset day if it exceeds the new month's max days
    if (int.parse(selectedDay) > daysInMonth) {
      selectedDay = daysInMonth.toString().padLeft(2, '0');
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937), // Biru gelap seperti footer/backend
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Date Pickers
                  const Text(
                    "Planned Date:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                  // 3. Exercise Input (FIXED Implementation)
                  const Text(
                    "1. Cari Latihan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Autocomplete Widget
                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Fungsi ini sekarang aman dipanggil
                      return searchExercises(textEditingValue.text);
                    },

                    // Menentukan string apa yang ditampilkan di text field saat opsi dipilih
                    displayStringForOption: (option) => option['name'],

                    onSelected: (Map<String, dynamic> selection) {
                      setState(() {
                        selectedExerciseId = selection['id'];
                      });
                      // Opsional: Tutup keyboard setelah memilih
                      FocusScope.of(context).unfocus();
                    },

                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: const InputDecoration(
                              hintText: "e.g. Bench Press",
                              border:
                                  UnderlineInputBorder(), // Atau OutlineInputBorder() sesuai selera
                              suffixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                  ),

                  const SizedBox(height: 20),

                  // 4. Sets & Reps Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "2. Sets",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _setsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "cth: 3",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "3. Reps",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "cth: 10",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 5. Add Planner Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1F2937,
                        ), // Biru gelap konsisten
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: addPlan,
                      child: const Text(
                        "Tambahkan ke Rencana",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. Log Activities List
                  const Text(
                    "Rencana Latihan Tanggal Ini",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1, color: Colors.black12),

                  FutureBuilder<List<WorkoutPlan>>(
                    future: fetchPlans(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueGrey[50],
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.blueGrey,
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
                                trailing: plan.isCompleted
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.circle_outlined,
                                        color: Colors.grey,
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
          ],
        ),
      ),
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
            icon: const Icon(Icons.arrow_drop_down),
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
