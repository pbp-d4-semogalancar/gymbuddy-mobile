import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/workout_plan.dart';

class WorkoutLogPage extends StatefulWidget {
  const WorkoutLogPage({super.key});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends State<WorkoutLogPage> {
  // Inputs
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  // We need to store the selected Exercise ID to send to Django
  int? selectedExerciseId;

  // Date Selection (Default to Today)
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = _numToMonth(DateTime.now().month);
  String selectedDay = DateTime.now().day.toString().padLeft(2, '0');

  // Backend URL (Use 10.0.2.2 for Android Emulator)
  final String domain = "http://10.0.2.2:8000";

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
  // Calls your GetPlansForDateAPIView
  Future<List<WorkoutPlan>> fetchPlans() async {
    String dateString =
        "$selectedYear-${_monthToNum(selectedMonth)}-$selectedDay";
    final url = Uri.parse(
      '$domain/planner/api/get-plans-for-date/?date=$dateString',
    );

    // NOTE: You might need to add headers: {"Cookie": ...} here if using raw http
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> plansJson = data['plans'] ?? [];
      return plansJson.map((json) => WorkoutPlan.fromJson(json)).toList();
    } else {
      print("Fetch Error: ${response.statusCode}");
      return [];
    }
  }

  // --- API 2: Search Exercises (Autocomplete) ---
  // Calls your ExerciseSearchJSONView
  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    if (query.length < 2) return [];

    final url = Uri.parse('$domain/planner/search-exercises/?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Your Django view returns: {'exercises': [{'id': 1, 'name': '...'}, ...]}
      return List<Map<String, dynamic>>.from(data['exercises']);
    }
    return [];
  }

  // --- API 3: Add New Plan ---
  // Calls your AddPlanAPIView
  Future<void> addPlan() async {
    if (selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an exercise")),
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
          // "Cookie": ... // Again, session cookie might be needed here
        },
        body: json.encode({
          "exercise_id": selectedExerciseId,
          "sets": int.tryParse(_setsController.text) ?? 0,
          "reps": int.tryParse(_repsController.text) ?? 0,
          "plan_date": dateString,
        }),
      );

      if (response.statusCode == 201) {
        // 201 Created
        setState(() {
          // Clear inputs and refresh the list
          _setsController.clear();
          _repsController.clear();
          selectedExerciseId = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Workout Added!")));
      } else {
        print("Add Error: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to add workout")));
      }
    } catch (e) {
      print("Error: $e");
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
            // 1. Banner (Matches Figma Visuals)
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.grey, // Placeholder for your banner image
                // image: DecorationImage(image: AssetImage('assets/images/banner.png'), fit: BoxFit.cover),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Back button in case you navigated here from Login
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
                  // 2. Date Pickers (Year, Month, Date)
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

                  // 3. Exercise Input (Autocomplete)
                  const Text(
                    "Exercises",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Type to search:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return searchExercises(textEditingValue.text);
                    },
                    displayStringForOption: (option) => option['name'],
                    onSelected: (Map<String, dynamic> selection) {
                      selectedExerciseId = selection['id'];
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: const InputDecoration(
                              hintText: "e.g. Bench Press",
                              border: UnderlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                  ),

                  const SizedBox(height: 20),

                  // 4. Sets & Reps Inputs
                  const Text(
                    "Sets & Reps",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _setsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Sets",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Reps",
                            border: UnderlineInputBorder(),
                          ),
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
                          0xFF555555,
                        ), // Dark Grey matching design
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: addPlan,
                      child: const Text(
                        "Add Planner",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. Log Activities List (Visuals match Figma card)
                  const Text(
                    "Your Log Activities for Today",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1, color: Colors.black),
                  FutureBuilder<List<WorkoutPlan>>(
                    future:
                        fetchPlans(), // Reloads whenever fetchPlans is called
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text("No activities for this date."),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final plan = snapshot.data![index];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan.exerciseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${plan.sets} Sets x ${plan.reps} Reps",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  // Extra space at bottom
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for building uniform dropdowns
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton<String>(
            value: items.contains(currentVal) ? currentVal : items[0],
            underline: Container(),
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
