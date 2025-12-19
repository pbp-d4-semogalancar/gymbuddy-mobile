import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek platform
import 'package:gymbuddy/widgets/left_drawer.dart';
import 'package:gymbuddy/screens/community_page.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'user_profile/profile_loader_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variabel untuk progress (0.0 - 1.0)
  double _progressPercentage = 0.0;
  int _onTimeCompleted = 0;
  int _totalPlans = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Gunakan addPostFrameCallback agar aman akses Provider context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProgress();
    });
  }

  // [PERBAIKAN] Fetch Progress dengan Autentikasi (CookieRequest)
  Future<void> _fetchProgress() async {
    final request = context.read<CookieRequest>();
    final now = DateTime.now();

    // Tentukan Domain (Localhost Android vs Web)
    final String domain = kIsWeb
        ? "http://127.0.0.1:8000"
        : "http://10.0.2.2:8000";
    final url =
        '$domain/planner/api/get-logs/?year=${now.year}&month=${now.month}';

    try {
      // Panggil API dengan session login
      final response = await request.get(url);

      if (mounted) {
        setState(() {
          _totalPlans = response['total_plans'] ?? 0;
          _onTimeCompleted = response['on_time_completed'] ?? 0;

          // Ambil persentase dari backend (misal 50.0) dan ubah ke 0.5
          double backendPercentage = (response['percentage'] ?? 0.0).toDouble();
          _progressPercentage = backendPercentage / 100.0;

          // Validasi range 0.0 - 1.0
          if (_progressPercentage > 1.0) _progressPercentage = 1.0;
          if (_progressPercentage < 0.0) _progressPercentage = 0.0;

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching home progress: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _progressPercentage = 0.0;
        });
      }
    }
  }

  // --- HEADER / TOP BAR ---
  Widget _topBar() {
    return Builder(
      builder: (context) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.25)),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Gym',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Buddy',
                        style: TextStyle(color: Colors.grey.shade200),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BANNER & PROGRESS BAR ---
  Widget _progressBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: SizedBox(
        width: double.infinity,
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                "lib/Assets/Background.jpg",
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) =>
                    Container(color: Colors.grey.shade800),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome Back, Buddy! 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Container Statistik
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Monthly Progress",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${(_progressPercentage * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progressPercentage,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade600,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _totalPlans == 0
                                ? "No plans yet. Let's start!"
                                : "$_onTimeCompleted of $_totalPlans workouts completed (On Time)",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TUTORIAL SECTION ---
  Widget _tutorialSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Explore Your Workout Tutorial",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTutorialCard(
                  title: "Bench Press",
                  muscle: "Chest",
                  req: "Barbell",
                  imagePath: "lib/Assets/HowTo_in_MainPage.jpg",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTutorialCard(
                  title: "Lat Pulldown",
                  muscle: "Back",
                  req: "Cable",
                  imagePath: "lib/Assets/HowTo_in_MainPage2.jpg",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard({
    required String title,
    required String muscle,
    required String req,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Target Muscle: $muscle",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  "Requirement: $req",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileLoaderPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Text(
                        "Step-by-Step in Here",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMMUNITY SECTION ---
  Widget _communitySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Community Highlights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommunityPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Create a new thread",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildDummyThreadItem("Tips: Cara bench press yang benar", "Dery"),
          _buildDummyThreadItem("My 30 days transformation result!", "Bambang"),
          _buildDummyThreadItem("Suplemen terbaik untuk pemula?", "Siti"),
        ],
      ),
    );
  }

  Widget _buildDummyThreadItem(String title, String user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text("Posted by $user", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityPage()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const LeftDrawer(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          Widget page;
          switch (index) {
            case 1:
              page = const HowtoPage();
              break;
            case 2:
              page = const LogActivityPage(); // Mengarah ke LogActivityPage
              break;
            case 3:
              page = const CommunityPage();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'How To',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _progressBanner(), // Sekarang sudah USER-SPECIFIC
                    _tutorialSection(),
                    const SizedBox(height: 10),
                    _communitySection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
