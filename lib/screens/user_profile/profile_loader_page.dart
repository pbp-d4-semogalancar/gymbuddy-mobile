import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/models/user_profile.dart';
import 'package:gymbuddy/screens/user_profile/user_profile_page.dart';
import 'package:gymbuddy/providers/user_provider.dart';
import 'package:gymbuddy/screens/user_profile/user_profile_form.dart';

class ProfileLoaderPage extends StatefulWidget {
  // Jika null = profil sendiri
  // Jika ada int angka = lihat profil sesuai user ID
  final int? userId;

  const ProfileLoaderPage({super.key, this.userId});

  @override
  State<ProfileLoaderPage> createState() => _ProfileLoaderPageState();
}

class _ProfileLoaderPageState extends State<ProfileLoaderPage> {

  Future<UserProfileEntry?> fetchUserProfile(BuildContext context, CookieRequest request) async {
    int targetId;

    // Logic penentuan ID untuk profile
    if (widget.userId != null) {
      targetId = widget.userId!;
    } else {
      final userProvider = context.read<UserProvider>(); // ambil id sendiri
      if (userProvider.userId == null) {
        throw Exception("User ID tidak ditemukan. Silakan login ulang.");
      }
      targetId = userProvider.userId!;
    }

    // --- REQUEST KE BACKEND (DENGAN ID) ---
    // ambil data dari show_json_by_id
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome, use URL http://localhost:8000
    final response = await request.get('http://localhost:8000/profile/json/$targetId/');

    // Parsing JSON ke Model
    return UserProfileEntry.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: FutureBuilder<UserProfileEntry?>(
        // baca Provider di dalam fungsi future
        future: fetchUserProfile(context, request),
        builder: (context, snapshot) {

          if (snapshot.data == null) {
            return const UserProfileForm();
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: Center(child: Text("Gagal memuat: ${snapshot.error}")),
            );
          }

          // Empty state
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text("Profil tidak ditemukan")),
            );
          }

          // Success state -> Tampilkan UI
          return UserProfilePage(userProfile: snapshot.data!);
        },
      ),
    );
  }
}