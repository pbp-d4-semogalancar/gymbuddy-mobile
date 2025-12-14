import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../screens/workout_plan_page.dart'; // Untuk tombol Buat Rencana
import '../service/planner_service.dart'; // Import service yg baru dibuat
import '../widgets/left_drawer.dart';

class LogActivityPage extends StatefulWidget {
  final PlannerService? service; 
  
  const LogActivityPage({super.key, this.service});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  late PlannerService _service = PlannerService();

  // State Filter
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _selectedWeek = ""; // Kosong berarti "Semua Minggu"

  // Data Statistik & List
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
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Panggil service (sesuaikan parameter dengan API backend Anda)
      final data = await _service.fetchWorkoutLogs(
        _selectedYear,
        _selectedMonth,
        weekStart: _selectedWeek,
      );
      setState(() {
        _logData = data;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Helper untuk generate minggu (sederhana)
  List<String> _getWeeksInMonth(int year, int month) {
    // Idealnya data ini didapat dari Backend agar sinkron
    // Ini contoh dummy placeholder
    return ["2025-10-01", "2025-10-08", "2025-10-15", "2025-10-22"];
  }

  void _showCompletionDialog(WorkoutPlan plan) {
    TextEditingController descController = TextEditingController(
      text: plan.description ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(plan.isCompleted ? 'Edit Catatan' : 'Tandai Selesai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Latihan: ${plan.exerciseName}"),
              SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Catatan Latihan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await _service.completeLog(
                  plan.id,
                  descController.text,
                );
                if (success) {
                  Navigator.pop(context);
                  _fetchData(); // Refresh data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Log berhasil disimpan!")),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Latihan Anda'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BAGIAN FILTER ---
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Dropdown Tahun
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Tahun',
                            border: OutlineInputBorder(),
                          ),
                          items: _years
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedYear = val!);
                            _fetchData();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // Dropdown Bulan
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'Bulan',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(
                            12,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(_months[index]),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() => _selectedMonth = val!);
                            _fetchData();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Dropdown Minggu
                  DropdownButtonFormField<String>(
                    value: _selectedWeek.isEmpty ? null : _selectedWeek,
                    decoration: InputDecoration(
                      labelText: 'Minggu',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text("-- Semua Minggu --"),
                      ),
                      ..._getWeeksInMonth(_selectedYear, _selectedMonth).map(
                        (w) => DropdownMenuItem(
                          value: w,
                          child: Text("Minggu ($w)"),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedWeek = val ?? "");
                      _fetchData();
                    },
                  ),
                  SizedBox(height: 10),
                  // Tombol Buat Rencana (Dipindah ke sini sesuai request)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutLogPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        "Buat Rencana Baru",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.grey[900], // Warna hitam/abu gelap
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // --- 2. BAGIAN STATISTIK ---
            if (_logData != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(
                    0xFF1F2937,
                  ), // Warna biru gelap (mirip footer/gray-800)
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Statistik ${_logData!['period_name'] ?? 'Periode Ini'}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem("Total", "${_logData!['total_plans']}"),
                        _buildStatItem(
                          "Selesai",
                          "${_logData!['completed_plans']}",
                        ),
                        _buildStatItem(
                          "Tepat Waktu",
                          "${_logData!['percentage']}%",
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "*Target tercapai dihitung berdasarkan log yang diselesaikan tepat waktu.",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // --- 3. DAFTAR LOG / EMPTY STATE ---
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_logData == null || (_logData!['plans'] as List).isEmpty)
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // Abu terang
                      border: Border.all(
                        color: Color(0xFF1F2937),
                      ), // Border biru gelap
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Belum Ada Log Latihan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tidak ada rencana latihan ditemukan untuk periode ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (_logData!['plans'] as List).length,
                    itemBuilder: (context, index) {
                      var planJson = _logData!['plans'][index];
                      // Parsing manual atau gunakan model jika response API sudah rapi
                      // Anggap planJson sudah sesuai struktur model
                      WorkoutPlan plan = WorkoutPlan.fromJson(planJson);

                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          side: plan.isCompleted
                              ? BorderSide(color: Colors.green.withOpacity(0.5))
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: plan.isCompleted
                            ? Colors.green[50]
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.exerciseName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${plan.sets} sets x ${plan.reps} reps | ${plan.planDate.day} ${_months[plan.planDate.month - 1]}",
                                    ),
                                    if (plan.isCompleted)
                                      Container(
                                        margin: EdgeInsets.only(top: 8),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          plan.description ??
                                              "Tidak ada catatan",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (plan.isCompleted)
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.amber[700],
                                  ),
                                  onPressed: () => _showCompletionDialog(plan),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => _showCompletionDialog(plan),
                                  child: Text("Selesai"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
