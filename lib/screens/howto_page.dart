import 'package:flutter/material.dart';
import 'package:gymbuddy/models/exercise.dart';
import 'package:gymbuddy/service/howto_service.dart';


class HowtoPage extends StatefulWidget {
  const HowtoPage({super.key});

  @override
  State<HowtoPage> createState() => _HowtoPageState();
}

class _HowtoPageState extends State<HowtoPage> {
  late Future<List<Exercise>> exercisesFuture;

  // NEW → List opsi diambil dari API, bukan hardcoded
  List<String> muscleOptions = [];
  List<String> equipmentOptions = [];

  // State filter
  String? selectedMuscle;
  String? selectedEquipment;

  @override
  void initState() {
    super.initState();

    // Load data exercise
    exercisesFuture = HowToService.fetchExercises();

    // NEW → Load opsi filter
    loadFilterOptions();
  }

  // NEW → Mengambil unique muscle & equipment dari API
  void loadFilterOptions() async {
    final result = await HowToService.fetchOptions();

    setState(() {
      muscleOptions = result["muscles"] ?? [];
      equipmentOptions = result["equipments"] ?? [];
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
        title: const Text(
          "How To Exercise",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children: [
          // ===========================
          //         FILTER UI
          // ===========================
          Padding(
            padding: const EdgeInsets.all(12.0),
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

                const SizedBox(width: 12),

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

          // ===========================
          //       LIST EXERCISE
          // ===========================
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
                  return const Center(child: Text("Tidak ada data exercise"));
                }

                final exercises = snapshot.data!;

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(ex.exerciseName),
                        subtitle: Text(ex.mainMuscle),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // detail page nanti
                        },
                      ),
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
