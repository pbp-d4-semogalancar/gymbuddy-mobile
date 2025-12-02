import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';

class UserProfilePage extends StatelessWidget {
  final UserProfileEntry userProfile;

  const UserProfilePage({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna sesuai desain referensi
    const Color darkHeaderColor = Color(0xFF2C2C2C); // header appbar
    const Color inputBoxColor = Color(0xFF4A4A4A);   // kotak Abu-abu gelap
    const Color labelColor = Colors.black;           // warna label tulisan

    final String? imageUrl = userProfile.profilePicture;

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

            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Your Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // BAGIAN INFO (Foto, Nama, Bio)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PROFILE PICTURE LOGIC ---
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(imageUrl),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- DISPLAY NAME ---
                  _buildLabel("Display Name:", labelColor),
                  const SizedBox(height: 8),
                  _buildInfoBox(userProfile.displayName, inputBoxColor),

                  const SizedBox(height: 20),

                  // --- BIO ---
                  _buildLabel("Bio:", labelColor),
                  const SizedBox(height: 8),
                  _buildInfoBox(
                    userProfile.bio.isNotEmpty ? userProfile.bio : "No bio available.",
                    inputBoxColor,
                    isMultiLine: true,
                  ),

                  const SizedBox(height: 24),

                  // --- FAVORITE WORKOUTS LABEL ---
                  _buildLabel("Favorite Workouts:", labelColor),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 3. GRID WORKOUTS (SliverGrid)
          if (userProfile.favoriteWorkouts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Wrap(
                  spacing: 10.0, // Jarak horizontal antar item
                  runSpacing: 10.0, // Jarak vertikal antar baris
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
                      // MainAxisSize.min agar lebar kotak mengikuti panjang teks
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
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "No favorite workouts added.",
                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ),
            ),

          // spacer bagian bawah
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // --- LOGIC GAMBAR UTAMA ---
  Widget _buildProfileImage(String? url) {
    // jika url ada, load gambar
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        headers: const {"Connection": "close"},

        // jika gagal load, tampilkan icon sebagai profile picture default
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.account_circle,
            size: 120,
            color: Colors.grey,
          );
        },
        // loading state
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // 3. Jika URL Null, Tampilkan ICON
    else {
      return const Icon(
        Icons.account_circle,
        size: 120,
        color: Colors.grey,
      );
    }
  }

  // Helper Widget: Label Teks Bold
  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18, // Ukuran font besar
        fontWeight: FontWeight.w800, // Extra Bold
        color: color,
      ),
    );
  }

  // Helper Widget: Kotak Abu-abu (Read Only)
  Widget _buildInfoBox(String text, Color bgColor, {bool isMultiLine = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      // Jika multiline (bio), tingginya fix agak besar. Jika tidak, menyesuaikan konten.
      height: isMultiLine ? 100 : null,
      alignment: isMultiLine ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70, // Teks putih agak pudar
          fontSize: 14,
        ),
      ),
    );
  }
}