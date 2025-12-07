import 'package:flutter/material.dart';
import 'package:gymbuddy/models/exercise.dart';
import 'package:gymbuddy/service/howto_service.dart';
import 'package:gymbuddy/widgets/howto_exercise_widget.dart';
import 'package:gymbuddy/screens/exercise_widgets.dart';


class HowtoPage extends StatefulWidget {
  const HowtoPage({super.key});

  @override
  State<HowtoPage> createState() => _HowtoPageState();
}

class _HowtoPageState extends State<HowtoPage> {
  late Future<List<Exercise>> exercisesFuture;

  // dynamic filter options (ambil dari API)
  List<String> muscleOptions = [];
  List<String> equipmentOptions = [];

  // selected filter
  String? selectedMuscle;
  String? selectedEquipment;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    exercisesFuture = HowToService.fetchExercises();

    // load options from API
    var options = await HowToService.fetchOptions();

    setState(() {
      muscleOptions = options["muscles"] ?? [];
      equipmentOptions = options["equipments"] ?? [];
    });
  }

  void applyFilter() {
    setState(() {
      exercisesFuture = HowToService.fetchExercises(
        muscle: selectedMuscle,
        equipment: selectedEquipment,
      );
    });
  }

  void resetFilter() {
    setState(() {
      selectedMuscle = null;
      selectedEquipment = null;
      exercisesFuture = HowToService.fetchExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How To Exercise", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children: [

          // FILTERING BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [

                // MUSCLE FILTER
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMuscle,
                    decoration: const InputDecoration(labelText: "Muscle"),
                    items: muscleOptions
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) {
                      selectedMuscle = value;
                      applyFilter();
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // EQUIPMENT FILTER
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedEquipment,
                    decoration: const InputDecoration(labelText: "Equipment"),
                    items: equipmentOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      selectedEquipment = value;
                      applyFilter();
                    },
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: resetFilter,
                )
              ],
            ),
          ),

          // LIST
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: exercisesFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada exercise"));
                }

                final exercises = snapshot.data!;

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return ExerciseCard(
                      exercise: ex,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailPage(exercise: ex),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
