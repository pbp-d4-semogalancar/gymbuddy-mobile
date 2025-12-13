import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';
import 'package:gymbuddy/widgets/unsaved_changes_bar.dart';

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
      final String url = 'http://localhost:8000/profile/edit/api/';

      final response = await request.post(
        url,
        {
          "display_name": _displayNameController.text,
          "bio": _bioController.text,
          "profile_picture": _profilePictureController.text,
          "favorite_workouts": jsonEncode(
            _currentWorkouts.map((w) => w.id).toList(),
          ),
        },
      );

      if (mounted) {
        if (response['success'] == true || response['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil berhasil disimpan!")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${response['message']}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

                            ProfilePictureDisplay(
                              imageUrl: displayUrl,
                              size: 120,
                            ),
                            if (isOwner)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => setState(() => _showUrlField = !_showUrlField),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                                    child: Icon(_showUrlField ? Icons.close : Icons.edit, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (_showUrlField && isOwner) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _profilePictureController,
                            decoration: InputDecoration(
                              labelText: "Image URL",
                              hintText: "Paste image link here...",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.link),
                              isDense: true,
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                        // --- FORM ---
                        _buildLabel("Display Name"),
                        _buildEditableBox(_displayNameController, isOwner),
                        const SizedBox(height: 20),
                        _buildLabel("Bio"),
                        _buildEditableBox(_bioController, isOwner, isMultiLine: true),

                        const SizedBox(height: 24),
                        _buildLabel("Favorite Workouts"),

                        // --- CHIPS ---
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [
                            ..._currentWorkouts.map((w) => Chip(
                                label: Text(w.exerciseName),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onDeleted: isOwner
                                  ? () {
                                setState(() {
                                  _currentWorkouts.removeWhere((x) => x.id == w.id);
                                  _checkForChanges();
                                });
                              } : null,
                            )),
                            if (isOwner)
                              ActionChip(
                                label: const Icon(Icons.add, size: 16, color: Colors.white),
                                backgroundColor: Colors.blueAccent,
                                onPressed: () => _showAddWorkoutDialog(context),
                              )
                          ],
                        ),

                        if(isOwner) ...[
                          const SizedBox(height: 40),
                          const Divider(),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete Account", style: TextStyle(color: Colors.red)),
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

  Widget _buildEditableBox(TextEditingController ctrl, bool enabled, {bool isMultiLine = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        maxLines: isMultiLine ? 4 : 1,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    String val = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Workout (TEMP)"),
        content: TextField(
          autofocus: true,
          onChanged: (v) => val = v,
          decoration: const InputDecoration(hintText: "Workout name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (val.isNotEmpty) {
                // ❗ dummy Exercise
                _addWorkout(
                  FavoriteWorkout(
                    id: -DateTime.now().millisecondsSinceEpoch,
                    exerciseName: val,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addWorkout(FavoriteWorkout workout) {
    if (!_currentWorkouts.any((w) => w.id == workout.id)) {
      setState(() {
        _currentWorkouts.add(workout);
        _checkForChanges();
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Delete Account?"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))],
    ));
  }
}

class ProfilePictureDisplay extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfilePictureDisplay({
    super.key,
    required this.imageUrl,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200, // Warna background saat loading
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // Cek null atau string kosong
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        // Key penting agar widget me-refresh saat URL berubah
        key: ValueKey(imageUrl),
        // Header close membantu mencegah koneksi nge-hang di beberapa device
        headers: const {"Connection": "close"},

        errorBuilder: (context, error, stackTrace) {
          // Debugging: Print error di console jika gambar tidak muncul
          debugPrint("Error loading profile image: $error");
          return Icon(Icons.broken_image, size: size * 0.5, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Icon(Icons.person, size: size * 0.6, color: Colors.grey);
    }
  }
}