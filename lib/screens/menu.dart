import 'package:flutter/material.dart';
import 'package:gymbuddy/widgets/left_drawer.dart';
import 'package:gymbuddy/widgets/item_card.dart';
import 'package:gymbuddy/screens/user_profile/profile_loader_page.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String nama = "Lionel Messi"; //nama
  final String npm = "2406275678"; //npm
  final String kelas = "B"; //kelas

  final List<ItemHomepage> items = [
    ItemHomepage("How To", Icons.question_mark, Colors.black),
    ItemHomepage("Log Aktivitas", Icons.add_task, Colors.black),
    ItemHomepage("Komunitas", Icons.people, Colors.black),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Shadow tipis (shadow-sm)
        // Mengubah warna icon hamburger menu menjadi hitam
        iconTheme: const IconThemeData(color: Colors.black),

        // Logo Text: "Gym" (Abu-abu) + "Buddy" (Hitam)
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ), // text-2xl font-bold
            children: [
              TextSpan(
                text: 'Gym',
                style: TextStyle(color: Colors.grey[500]), // text-gray-500
              ),
              TextSpan(
                text: 'Buddy',
                style: TextStyle(color: Colors.grey[900]), // text-gray-900
              ),
            ],
          ),
        ),

        // Tombol di sebelah kanan (Actions)
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // Tombol "Halo, [Nama]"
                GestureDetector(
                  onTap: () {
                    // Navigasi ke UserProfilePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileLoaderPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900], // bg-gray-900
                      borderRadius: BorderRadius.circular(8), // rounded-md
                    ),
                    child: Text(
                      'Halo, $nama',
                      style: const TextStyle(
                        color: Colors.white, // text-white
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8), // Spasi antar elemen
                // Tombol Logout (ikon)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  tooltip: 'Logout',
                  onPressed: () {
                    // Implementasi logika logout di sini nanti
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logout berhasil (simulasi)"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      drawer: const LeftDrawer(),
      // Menggunakan SingleChildScrollView agar bisa scroll sampai footer
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- KONTEN UTAMA ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Text(
                      'Bangun Tubuh Impianmu Bersama GymBuddy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Info Cards (NPM, Nama, Kelas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoCard(title: 'NPM', content: npm),
                      InfoCard(title: 'Name', content: nama),
                      InfoCard(title: 'Class', content: kelas),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Grid Menu
                  GridView.count(
                    primary: false,
                    shrinkWrap: true, // Agar grid tidak scroll sendiri
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Jarak sebelum footer
            // --- WIDGET FOOTER ---
            const GymBuddyFooter(),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

// Widget Footer sesuai desain HTML
class GymBuddyFooter extends StatelessWidget {
  const GymBuddyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800], // bg-gray-800
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Footer
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Gym',
                  style: TextStyle(color: Colors.grey[400]), // text-gray-400
                ),
                const TextSpan(
                  text: 'Buddy',
                  style: TextStyle(color: Colors.white), // text-white
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'GymBuddy adalah platform kebugaran berbasis web untuk menemani kegiatan workout kamu 💪',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),

          const SizedBox(height: 24),

          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'gymbuddy@gmail.com',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey[700]),
          const SizedBox(height: 16),

          Center(
            child: Text(
              '© 2025 GymBuddy. Hak Cipta Dilindungi.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
