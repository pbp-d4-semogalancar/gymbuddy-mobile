import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';
import 'package:gymbuddy/widgets/profile_info_box.dart';
import 'package:gymbuddy/widgets/profile_picture_display.dart';

class UserProfilePage extends StatelessWidget {
  final UserProfileEntry userProfile;

  const UserProfilePage({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {

    final int? loggedInUserId = context.watch<UserProvider>().userId;

    // warna default
    const Color darkHeaderColor = Color(0xFF2C2C2C);
    const Color labelColor = Colors.black;

    final bool isOwner = loggedInUserId == userProfile.id;

    TextStyle labelStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: labelColor,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // APP BAR (Sliver)
          SliverAppBar(
            backgroundColor: darkHeaderColor,
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: 60.0,
            pinned: true,

            // tombol back custom
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_left,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // dynamic title appbar
              title: Text(
                isOwner ? "Your Profile" : "${userProfile.displayName}'s Profile",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // ISI BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PROFILE PICTURE ---
                  Center(
                    child: ProfilePictureDisplay(
                      imageUrl: userProfile.profilePicture,
                      size: 120,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- DISPLAY NAME ---
                  Text("Display Name:", style: labelStyle),
                  const SizedBox(height: 8),

                  ProfileInfoBox(text: userProfile.displayName),

                  const SizedBox(height: 20),

                  // --- BIO ---
                  Text("Bio:", style: labelStyle),
                  const SizedBox(height: 8),

                  ProfileInfoBox(
                    text: userProfile.bio.isNotEmpty ? userProfile.bio : "No bio available.",
                    isMultiLine: true,
                  ),

                  const SizedBox(height: 24),

                  // --- FAVORITE WORKOUTS ---
                  Text("Favorite Workouts:", style: labelStyle),
                  const SizedBox(height: 12),

                  if (userProfile.favoriteWorkouts.isNotEmpty)
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: userProfile.favoriteWorkouts.map((workout) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              )
                            ],
                          ),
                          child: Text(
                            workout,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      "No favorite workouts added.",
                      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 3. TOMBOL EDIT & DELETE
          SliverToBoxAdapter(
            child: isOwner
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 20),

                  // EDIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fitur Edit segera hadir!"))
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DELETE
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red.shade100)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ): const SizedBox.shrink(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text("Aksi ini tidak dapat dibatalkan. Yakin ingin menghapus akun?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}