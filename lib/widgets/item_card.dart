import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/community_page.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/screens/community_page.dart';

class ItemCard extends StatelessWidget {
  // Menampilkan kartu dengan ikon dan nama.

  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Material(
      // Menentukan warna latar belakang dari tema aplikasi.
      color: Theme.of(context).colorScheme.secondary,
      // Membuat sudut kartu melengkung.
      borderRadius: BorderRadius.circular(12),

      child: InkWell(
        // Aksi ketika kartu ditekan.
        onTap: () {
          // Menampilkan pesan SnackBar saat kartu ditekan.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!"))
            );


          // Navigate ke route yang sesuai (tergantung jenis tombol) (belum kepake)
          if (item.name == "How To") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HowtoPage(),
                )
            );
          } else if (item.name == "Log Aktivitas") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogActivityPage(),
                )
            );
          } else if (item.name == "Komunitas") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityPage(),
                )
            );
          }

          if (item.name == "Komunitas") { // <--- CEK NAMA ITEM CARD
            Navigator.push( // Gunakan push agar bisa kembali
                context,
                MaterialPageRoute(
                  // Arahkan ke CommunityPage
                  builder: (context) => const CommunityPage(), 
                )
            );
          }

        },
        // Container untuk menyimpan Icon dan Text
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              // Menyusun ikon dan teks di tengah kartu.
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}