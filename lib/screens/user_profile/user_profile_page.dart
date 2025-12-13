import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';
import 'package:gymbuddy/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';
import 'package:gymbuddy/widgets/user_profile/unsaved_changes_bar.dart';
import 'package:gymbuddy/widgets/user_profile/profile_picture_section.dart';
import 'package:gymbuddy/widgets/user_profile/favorite_workouts_section.dart';
import 'package:gymbuddy/widgets/user_profile/delete_profile_dialog.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfileEntry userProfile;

  const UserProfilePage({super.key, required this.userProfile});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _profilePictureController;

  late List<FavoriteWorkout> _currentWorkouts;

  List<Map<String, dynamic>>? _cachedFavoriteWorkouts;

  bool _hasChanges = false;
  bool _isSaving = false;
  bool _showUrlField = false;

  // --- KONFIGURASI URL ---
  final String _baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _resetState() {
    _displayNameController =
        TextEditingController(text: widget.userProfile.displayName);
    _bioController =
        TextEditingController(text: widget.userProfile.bio);
    _profilePictureController =
        TextEditingController(text: widget.userProfile.profilePicture ?? "");

    _currentWorkouts =
    List<FavoriteWorkout>.from(widget.userProfile.favoriteWorkouts);

    _displayNameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
    _profilePictureController.addListener(_checkForChanges);

    _hasChanges = false;
    _showUrlField = false;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    bool textChanged =
        _displayNameController.text != widget.userProfile.displayName ||
            _bioController.text != widget.userProfile.bio ||
            _profilePictureController.text != (widget.userProfile.profilePicture ?? "");

    bool workoutsChanged =
        _currentWorkouts.length != widget.userProfile.favoriteWorkouts.length ||
            !_currentWorkouts.every((w) =>
                widget.userProfile.favoriteWorkouts.any((o) => o.id == w.id));

    if (_hasChanges != (textChanged || workoutsChanged)) {
      setState(() {
        _hasChanges = textChanged || workoutsChanged;
      });
    }
  }

  Future<void> _saveChanges(CookieRequest request) async {
    setState(() => _isSaving = true);

    try {
      final url = '$_baseUrl/profile/edit/api/';

      final Map<String, dynamic> body = {
        "display_name": _displayNameController.text,
        "bio": _bioController.text,
        "profile_picture": _profilePictureController.text,
        "favorite_workouts": jsonEncode(
          _currentWorkouts.map((w) => w.id).toList(),
        ),
      };

      final response = await request.post(url, body);

      if (mounted && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan!")),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavoriteWorkouts(CookieRequest request) async {
    final res = await request.get(
      "$_baseUrl/profile/list-workouts/",
    );

    return List<Map<String, dynamic>>.from(res);
  }

  // --- HELPERS BUILDER ---

  String _getProxyUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    String encodedUrl = Uri.encodeComponent(originalUrl);
    return "$_baseUrl/profile/proxy-image/?url=$encodedUrl";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final int? loggedInUserId = context.watch<UserProvider>().userId;
    final bool isOwner = loggedInUserId == widget.userProfile.id;

    String rawUrl = _profilePictureController.text.trim();
    String displayUrl = _getProxyUrl(rawUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF2C2C2C),
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: 60.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    isOwner ? "Your Profile" : "${widget.userProfile.displayName}'s Profile",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- FOTO PROFIL ---
                        Stack(
                          children: [
                            ProfilePictureSection(
                              imageUrl: displayUrl,
                              isOwner: isOwner,
                              showUrlField: _showUrlField,
                              controller: _profilePictureController,
                              onToggleEdit: () {
                                setState(() => _showUrlField = !_showUrlField);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        // --- FORM ---
                        _buildLabel("Display Name"),
                        _buildEditableBox(
                          _displayNameController,
                          isOwner,
                          validator: (value) {
                            if (!isOwner) return null;
                            if (value == null || value.trim().isEmpty) {
                              return "Display name tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Bio"),
                        _buildEditableBox(_bioController, isOwner, isMultiLine: true),

                        const SizedBox(height: 24),
                        _buildLabel("Workout Favorit"),

                        // --- CHIPS ---
                        const SizedBox(height: 8),
                        FavoriteWorkoutsSection(
                          workouts: _currentWorkouts,
                          isOwner: isOwner,
                          hasChanges: _hasChanges,
                          onAdd: () => _showAddWorkoutDialog(context),
                          onRemove: (id) {
                            setState(() {
                              _currentWorkouts.removeWhere((w) => w.id == id);
                              _checkForChanges();
                            });
                          },
                        ),

                        if(isOwner) ...[
                          const SizedBox(height: 40),
                          TextButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text(
                              "Hapus Akun",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white, // teks + icon
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _showDeleteConfirmation(context),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isOwner && _hasChanges)
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: UnsavedChangesBar(
                isSaving: _isSaving,
                onReset: () {
                  setState(() => _resetState());
                  FocusScope.of(context).unfocus();
                },
                onSave: () {
                  if (_formKey.currentState!.validate()) {
                    _saveChanges(request);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildEditableBox(
      TextEditingController ctrl,
      bool enabled, {
        bool isMultiLine = false,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        maxLines: isMultiLine ? 4 : 1,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) async {
    final request = context.read<CookieRequest>();

    // LOADING STATE

    if (_cachedFavoriteWorkouts == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      _cachedFavoriteWorkouts = await fetchFavoriteWorkouts(request);

      if (!mounted) return;
      Navigator.pop(context);
    }

    _cachedFavoriteWorkouts ??= await fetchFavoriteWorkouts(request);

    final favoriteWorkouts = _cachedFavoriteWorkouts!;

    // TEMP STATE

    final Set<int> selectedIds =
    _currentWorkouts.map((w) => w.id).toSet();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Pilih Workout Favoritmu!"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: favoriteWorkouts.length,
                  itemBuilder: (_, i) {
                    final ex = favoriteWorkouts[i];
                    final int exId = ex['id'];
                    final String exName = ex['exercise_name'];

                    return CheckboxListTile(
                      value: selectedIds.contains(exId),
                      title: Text(
                        exName,
                        style: const TextStyle(color: Colors.black),
                      ),
                      activeColor: Colors.black,
                      checkColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedIds.add(exId);
                          } else {
                            selectedIds.remove(exId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentWorkouts = favoriteWorkouts
                          .where((ex) => selectedIds.contains(ex['id']))
                          .map((ex) => FavoriteWorkout(
                        id: ex['id'],
                        exerciseName: ex['exercise_name'],
                      ))
                          .toList();

                      _checkForChanges();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProfile(CookieRequest request) async {
    setState(() => _isSaving = true);

    try {
      final url =
          "$_baseUrl/profile/${widget.userProfile.id}/${widget.userProfile.username}/delete/";

      final response = await request.post(url, {
        "_method": "DELETE",
      });

      if (!mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun berhasil dihapus")),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Gagal menghapus akun")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("DELETE PROFILE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final request = context.read<CookieRequest>();

    showDialog(
      context: context,
      builder: (_) => DeleteProfileDialog(
        onConfirm: () => _deleteProfile(request),
      ),
    );
  }
}