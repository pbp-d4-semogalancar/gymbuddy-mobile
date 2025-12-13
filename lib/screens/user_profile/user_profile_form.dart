import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/models/user_profile.dart';
import 'package:gymbuddy/widgets/profile_picture_section.dart';
import 'package:gymbuddy/widgets/favorite_workouts_section.dart';

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({super.key});

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _profilePictureController = TextEditingController();

  List<FavoriteWorkout> _selectedWorkouts = [];
  bool _isSaving = false;
  bool _showUrlField = true;

  final String _baseUrl = "http://localhost:8000";

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  String _getProxyUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    return "$_baseUrl/profile/proxy-image/?url=${Uri.encodeComponent(originalUrl)}";
  }

  Future<List<Map<String, dynamic>>> fetchExercises(CookieRequest request) async {
    final res = await request.get("http://localhost:8000/howto/api/list/");
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> _submitProfile(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final body = {
        "display_name": _displayNameController.text.trim(),
        "bio": _bioController.text.trim(),
        "profile_picture": _profilePictureController.text.trim(),
        "favorite_workouts": jsonEncode(
          _selectedWorkouts.map((w) => w.id).toList(),
        ),
      };

      final response = await request.post(
        "http://localhost:8000/profile/create/api/",
        body,
      );

      if (mounted && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil dibuat!")),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final rawUrl = _profilePictureController.text.trim();
    final displayUrl = _getProxyUrl(rawUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Create Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FOTO PROFIL
              Center(
                child: ProfilePictureSection(
                  imageUrl: displayUrl,
                  isOwner: true,
                  showUrlField: _showUrlField,
                  controller: _profilePictureController,
                  onToggleEdit: () {
                    setState(() => _showUrlField = !_showUrlField);
                  },
                ),
              ),

              const SizedBox(height: 30),

              _label("Display Name"),
              _inputBox(
                _displayNameController,
                hint: "Your name",
                validator: (v) =>
                v == null || v.isEmpty ? "Display name wajib diisi" : null,
              ),

              const SizedBox(height: 20),
              _label("Bio"),
              _inputBox(
                _bioController,
                isMultiLine: true,
                hint: "Tell something about yourself",
              ),

              const SizedBox(height: 24),
              _label("Favorite Workouts"),
              FavoriteWorkoutsSection(
                workouts: _selectedWorkouts,
                isOwner: true,
                onAdd: () => _showAddWorkoutDialog(context),
                onRemove: (id) {
                  setState(() {
                    _selectedWorkouts.removeWhere((w) => w.id == id);
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _submitProfile(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- UI HELPERS ---
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _inputBox(
      TextEditingController controller, {
        bool isMultiLine = false,
        String? hint,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: isMultiLine ? 4 : 1,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// --- WORKOUT PICKER ---
  void _showAddWorkoutDialog(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final exercises = await fetchExercises(request);
    debugPrint(exercises.toString());

    final selectedIds = _selectedWorkouts.map((w) => w.id).toSet();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Select Favorite Workouts"),
          content: SizedBox(
            width: double.maxFinite, // ⬅️ PENTING
            height: 400,
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (_, i) {
                final ex = exercises[i];
                return CheckboxListTile(
                  value: selectedIds.contains(ex['id']),
                  title: Text(ex['exercise_name']),
                  onChanged: (checked) {
                    setDialogState(() {
                      checked == true
                          ? selectedIds.add(ex['id'])
                          : selectedIds.remove(ex['id']);
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedWorkouts = exercises
                      .where((ex) => selectedIds.contains(ex['id']))
                      .map((ex) => FavoriteWorkout(
                    id: ex['id'],
                    exerciseName: ex['exercise_name'],
                  ))
                      .toList();
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}