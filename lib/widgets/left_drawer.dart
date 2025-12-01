import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/community_page.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:gymbuddy/screens/user_profile/profile_loader_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/screens/login.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
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
                Padding(padding: EdgeInsets.all(10)),
                Text("Say no to olahraga ribet! 💪🏋️‍♂️",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // HomePage
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                )
              );
            },
          ),

          // How To
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('How To?'),
            // Bagian redirection ke page
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HowtoPage(),
                  )
              );
            },
          ),

          // Log Activity
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Log Activity'),
            // Bagian redirection ke page, misal form page
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogActivityPage(), // <= ubah ini, misal PlannerPage(), CommunityPage(), dll.
                  )
              );
            },
          ),

          // Community
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Community'),
            // Bagian redirection ke page, misal form page
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityPage(), // <= ubah ini, misal PlannerPage(), CommunityPage(), dll.
                  )
              );
            },
          ),

          // Community
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Profile'),
            // Bagian redirection ke page, misal form page
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileLoaderPage()
                  )
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
              // If you using chrome,  use URL http://localhost:8000
              final response = await request.logout(
                  "http://localhost:8000/auth/api/logout/");
              String message = response["message"];
              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("$message See you again, $uname."),
                  ));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                }
              }
            },
          ),

          /* note dari Rexy
          * TEMPLATE BUAT BAGIAN DRAWER
          * 1. COPY SELURUH ISI ListTile(
          * ...
          * ),
          * 2. ubah title dan routing pada builder: (context) => <page kalian>
          */
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('Dummy'),
            // Bagian redirection ke page, misal form page
            onTap: () {
              Navigator.pushReplacement( // bisa push atau pushreplacement
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(), // <= ubah ini, misal PlannerPage(), CommunityPage(), dll.
                  )
              );
            },
          ),
        ],
      ),
    );
  }
}