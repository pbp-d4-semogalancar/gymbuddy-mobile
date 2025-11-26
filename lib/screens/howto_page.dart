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

  @override
  void initState() {
    super.initState();
    exercisesFuture = HowToService.fetchExercises();
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
      body: FutureBuilder<List<Exercise>>(
        future: exercisesFuture,
        builder: (context, snapshot) {

          // sedang load
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // kalau error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // kalau data kosong
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
                    // nanti dibuat detail page  
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
