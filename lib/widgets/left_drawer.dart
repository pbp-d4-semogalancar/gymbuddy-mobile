import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/community_page.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:gymbuddy/screens/user_profile_page.dart';
import 'package:gymbuddy/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      // Background gelap agar tulisan putih terlihat
      backgroundColor: Colors.grey.shade900,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GymBuddy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your ultimate workout companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // 1. HOME
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),

          // 2. PROFILE
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),

          // 3. HOW TO
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('HowTo', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HowtoPage()),
              );
            },
          ),

          // 4. LOG ACTIVITY
          ListTile(
            leading: const Icon(Icons.history, color: Colors.white),
            title: const Text(
              'Log Activity',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogActivityPage(),
                ),
              );
            },
          ),

          // 5. COMMUNITY
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text(
              'Community',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CommunityPage()),
              );
            },
          ),

          // 6. LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              // [PERBAIKAN UTAMA]
              // Gunakan URL API '/auth/api/logout/' agar tidak error redirect.
              final response = await request.logout(
                "http://127.0.0.1:8000/auth/api/logout/",
              );

              String message = response["message"];
              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$message Sampai jumpa, $uname.")),
                  );
                  // Pindah ke halaman Login dan hapus semua rute sebelumnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
