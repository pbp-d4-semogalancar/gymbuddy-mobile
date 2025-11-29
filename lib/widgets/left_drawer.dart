import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/community_page.dart';

import 'package:gymbuddy/screens/menu.dart';


class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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