import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek platform
import 'package:gymbuddy/models/workout_plan.dart';
import 'package:gymbuddy/screens/workout_plan_page.dart';
import 'package:gymbuddy/service/planner_service.dart';
import 'package:gymbuddy/widgets/left_drawer.dart';
import 'package:gymbuddy/widgets/user_avatar.dart';
import 'package:gymbuddy/screens/community_page.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LogActivityPage extends StatefulWidget {
  final PlannerService? service;

  const LogActivityPage({super.key, this.service});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  late PlannerService _service;

  // State Filter Waktu
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // Filter Minggu (null artinya "Semua Minggu")
  String? _selectedWeekLabel;

  // Data Mentah dari Backend
  Map<String, dynamic>? _logData;
  bool _isLoading = true;

  final List<int> _years = [2024, 2025, 2026];
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PlannerService();

    // Kita panggil fetch setelah frame pertama agar bisa akses 'context.read'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  // --- SOLUSI REVISI 3: USER ISOLATION ---
  // Kita fetch langsung pakai 'request' dari Provider agar Cookies terbawa.
  // Ini memastikan data yang diambil adalah milik User yang sedang login (A/B).
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final String domain = kIsWeb
        ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
        : "http://10.0.2.2:8000";
    final url =
        '$domain/planner/api/get-logs/?year=$_selectedYear&month=$_selectedMonth';

    try {
      // Menggunakan request.get (Authenticated Request)
      final response = await request.get(url);

      setState(() {
        _logData = response;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching logs: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC GENERATE MINGGU ---
  List<Map<String, dynamic>> _generateWeeks(int year, int month) {
    List<Map<String, dynamic>> weeks = [];
    DateTime currentDate = DateTime(year, month, 1);
    DateTime monthEnd = DateTime(year, month + 1, 0);
    int weekIndex = 1;

    while (currentDate.isBefore(monthEnd) ||
        currentDate.isAtSameMomentAs(monthEnd)) {
      int daysUntilSunday = 7 - currentDate.weekday;
      DateTime weekEnd = currentDate.add(Duration(days: daysUntilSunday));
      if (weekEnd.isAfter(monthEnd)) weekEnd = monthEnd;

      weeks.add({
        "label": "Minggu $weekIndex (${currentDate.day}-${weekEnd.day})",
        "start": currentDate,
        "end": weekEnd,
      });

      currentDate = weekEnd.add(const Duration(days: 1));
      weekIndex++;
    }
    return weeks;
  }

  // --- LOGIC FILTERING ---
  bool _isPlanInSelectedWeek(WorkoutPlan plan) {
    if (_selectedWeekLabel == null) return true;

    List<Map<String, dynamic>> weeks = _generateWeeks(
      _selectedYear,
      _selectedMonth,
    );
    var weekRange = weeks.firstWhere(
      (w) => w['label'] == _selectedWeekLabel,
      orElse: () => <String, dynamic>{},
    );

    if (weekRange.isEmpty) return true;

    DateTime start = weekRange['start'];
    DateTime end = weekRange['end'];
    DateTime planDate = DateTime(
      plan.planDate.year,
      plan.planDate.month,
      plan.planDate.day,
    );
    DateTime s = DateTime(start.year, start.month, start.day);
    DateTime e = DateTime(end.year, end.month, end.day);

    return (planDate.isAtSameMomentAs(s) || planDate.isAfter(s)) &&
        (planDate.isAtSameMomentAs(e) || planDate.isBefore(e));
  }

  // --- FIX: UI DIALOG & LOGIC COMPLETION ---
  void _showCompletionDialog(WorkoutPlan plan) {
    TextEditingController descController = TextEditingController(
      text: plan.description ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Judul Bold dan lebih kecil
          title: Text(
            plan.isCompleted ? 'Edit Catatan' : 'Tandai Selesai',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Latihan: ${plan.exerciseName}"),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                // Input User: Style Normal
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  // Hint diperkecil
                  labelText: 'Catatan Latihan (Opsional)',
                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  floatingLabelStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.black)),
            ),

            // [BAGIAN UTAMA YANG DIPERBAIKI]
            ElevatedButton(
              onPressed: () async {
                // 1. Ambil request auth dari Provider
                final request = context.read<CookieRequest>();

                // 2. Siapkan URL (Pastikan ada trailing slash '/' di akhir agar tidak error Django)
                final String domain = kIsWeb
                    ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
                    : "http://10.0.2.2:8000";
                final url = '$domain/planner/api/log/complete/${plan.id}/';

                try {
                  // 3. Kirim POST Request Auth
                  // Backend Anda membaca `request.POST.get('description')`, jadi kita kirim Map biasa
                  final response = await request.post(url, {
                    'description': descController.text,
                  });

                  // 4. Cek hasil dari backend
                  if (response['status'] == 'success') {
                    if (!mounted) return;
                    Navigator.pop(context); // Tutup dialog
                    _fetchData(); // Refresh list & progress bar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Log berhasil disimpan!")),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Gagal: ${response['message'] ?? 'Terjadi kesalahan'}",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  // Jika session mati atau error koneksi
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // --- UI COMPONENTS ---

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
              UserAvatar(
                isCurrentUser: true, 
                radius: 18,
                onTap: () => Scaffold.of(context).openDrawer(),
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

  Widget _headerBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                "lib/Assets/Background.jpg",
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) =>
                    Container(color: Colors.grey.shade800),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Activity Log",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Track, Analyze, and Improve!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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

  Widget _filterSection() {
    List<Map<String, dynamic>> weeksAvailable = _generateWeeks(
      _selectedYear,
      _selectedMonth,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter By Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<int>(
                        label: "Year",
                        value: _selectedYear,
                        items: _years,
                        itemLabel: (y) => y.toString(),
                        onChanged: (val) {
                          setState(() {
                            _selectedYear = val!;
                            _selectedWeekLabel = null;
                          });
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown<int>(
                        label: "Month",
                        value: _selectedMonth,
                        items: List.generate(12, (index) => index + 1),
                        itemLabel: (m) => _months[m - 1],
                        onChanged: (val) {
                          setState(() {
                            _selectedMonth = val!;
                            _selectedWeekLabel = null;
                          });
                          _fetchData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  label: "Week",
                  value: _selectedWeekLabel,
                  items: [
                    null,
                    ...weeksAvailable.map((w) => w['label'] as String),
                  ],
                  itemLabel: (w) => w == null ? "-- All Weeks --" : w,
                  onChanged: (val) {
                    setState(() {
                      _selectedWeekLabel = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SOLUSI REVISI 2: DYNAMIC STATISTICS ---
  // Widget ini sekarang menerima list 'plans' yang sudah terfilter
  // dan menghitung statistik secara real-time berdasarkan list tersebut.
  Widget _statisticsSection(List<WorkoutPlan> plans) {
    if (_logData == null) return const SizedBox.shrink();

    // Hitung statistik berdasarkan 'plans' yang ditampilkan (Filtered)
    int total = plans.length;
    int completed = plans.where((p) => p.isCompleted).length;
    int onTime = 0;

    // Logika On-Time (Sama dengan backend: completed_at date <= plan_date)
    for (var p in plans) {
      if (p.isCompleted && p.completedAt != null) {
        // Bandingkan tanggal saja
        DateTime cDate = DateTime(
          p.completedAt!.year,
          p.completedAt!.month,
          p.completedAt!.day,
        );
        DateTime pDate = DateTime(
          p.planDate.year,
          p.planDate.month,
          p.planDate.day,
        );
        if (cDate.isBefore(pDate) || cDate.isAtSameMomentAs(pDate)) {
          onTime++;
        }
      }
    }

    double progress = total > 0 ? (onTime / total) : 0.0;
    int percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Statistics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
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
                      "Completion Rate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$percentage%",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade600,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Total Plans", "$total"),
                    _buildStatItem("Completed", "$completed"),
                    _buildStatItem("On Time", "$onTime"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC GABUNGAN: LIST & STATS ---
  // Kita hitung list terfilter sekali saja di method build
  // lalu passing ke statistik dan list view.
  @override
  Widget build(BuildContext context) {
    final request = context
        .watch<CookieRequest>(); // Trigger rebuild jika auth berubah

    // 1. Siapkan Data Terfilter
    List<WorkoutPlan> displayedPlans = [];
    if (_logData != null && _logData!['plans'] != null) {
      List<dynamic> rawPlans = _logData!['plans'];
      for (var json in rawPlans) {
        WorkoutPlan plan = WorkoutPlan.fromJson(json);
        if (_isPlanInSelectedWeek(plan)) {
          displayedPlans.add(plan);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const LeftDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Widget page;
          switch (index) {
            case 0:
              page = const MyHomePage();
              break;
            case 1:
              page = const HowtoPage();
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
                    _headerBanner(),
                    const SizedBox(height: 20),
                    _filterSection(),

                    const SizedBox(height: 24),

                    // PASSING DATA TERFILTER KE STATISTIK
                    _statisticsSection(displayedPlans),

                    const SizedBox(height: 24),

                    // PASSING DATA TERFILTER KE LIST LOG
                    _logActivitiesList(displayedPlans),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LIST WIDGET ---
  Widget _logActivitiesList(List<WorkoutPlan> plans) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Log Activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tombol ADD
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutLogPage()),
              );
              if (result == true) {
                _fetchData();
              }
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
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Buat Rencana Baru",
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

          // List Items
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (plans.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: const [
                  Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No activities found in this period.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return _buildLogCard(plans[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogCard(WorkoutPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: plan.isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: plan.isCompleted
                        ? Colors.green.shade50
                        : Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: plan.isCompleted ? Colors.green : Colors.blueGrey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.exerciseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${plan.sets} Sets • ${plan.reps} Reps",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${plan.planDate.day} ${_months[plan.planDate.month - 1]} ${plan.planDate.year}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!plan.isCompleted)
                  ElevatedButton(
                    onPressed: () => _showCompletionDialog(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showCompletionDialog(plan),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (plan.isCompleted &&
                (plan.description?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Note: ${plan.description}",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T?> items,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item == null ? "-- Select --" : itemLabel(item),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
