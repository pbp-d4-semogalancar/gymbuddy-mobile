// lib/screens/community_page.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart'; 
import 'create_thread_page.dart'; 
import 'edit_thread_page.dart'; 
import '../models/community_thread.dart'; 
import 'thread_detail.dart';

// Enum untuk mengontrol state filter
enum ThreadFilter { all, myThreads }

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // --- ASUMSI DATA USER YANG LOGIN ---
  final String _currentLoggedInUsername = "deryyy"; 
  
  ThreadFilter _selectedFilter = ThreadFilter.all;
  
  // --- STATE DATA API ---
  List<NewThreadData> allThreads = []; 
  bool _isLoading = true;
  String? _error; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchThreads();
    });
  }

  // --- FUNGSI GET DARI DJANGO API ---
  Future<void> _fetchThreads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      
      // URL GET: Menggunakan localhost
      final response = await request.get("http://localhost:8000/community/api/threads/"); 

      if (response is List) {
        final fetchedThreads = response.map((data) {
          return NewThreadData.fromJson(data as Map<String, dynamic>, _currentLoggedInUsername);
        }).toList();
        
        setState(() {
          allThreads = fetchedThreads.reversed.toList();
        });
        
      } else {
        throw Exception("Invalid response format from server.");
      }

    } catch (e) {
      if (context.mounted) {
        setState(() {
          _error = "Gagal memuat thread. Pastikan Anda sudah login di Flutter.";
        });
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- LOGIC FILTER MENGGUNAKAN USERNAME DERYYY ---
  List<NewThreadData> get filteredThreads {
    if (_selectedFilter == ThreadFilter.myThreads) {
      return allThreads.where((thread) => thread.username == _currentLoggedInUsername).toList(); 
    }
    return allThreads;
  }
  
  // --- FUNGSI CUD LOGIC ---
  void _addThread(NewThreadData newThread) {
    setState(() {
      allThreads.insert(0, newThread); 
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Thread baru berhasil ditambahkan!")),
    );
  }

  void _updateThread(int originalIndex, NewThreadData updatedThread) {
    setState(() {
      if (originalIndex >= 0 && originalIndex < allThreads.length) {
          allThreads[originalIndex] = updatedThread; 
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thread berhasil diperbarui!")),
    );
  }
  
  // FUNGSI DELETE DENGAN API
Future<void> _deleteThread(int threadId) async {
  final request = context.read<CookieRequest>();

  try {
    final response = await request.post(
      "http://localhost:8000/community/api/thread/$threadId/delete/",
      {},
    );

    if (response.containsKey('success') && response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Thread berhasil dihapus!")),
      );
      Navigator.pop(context, true); // kembali ke halaman sebelumnya
    } else {
      String errorMsg = response['error'] ?? "Gagal menghapus thread.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $errorMsg")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Terjadi kesalahan koneksi saat menghapus.")),
    );
  }
}



  // --- WIDGET SESUAI DESAIN: HEADER DAN FILTER ---
  
  Widget _buildBanner() {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black54, // Overlay gelap
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Thread & Reply: Community Discussion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 5),
            Text('Tempatkan untuk membahas lebih banyak tentang workout mu', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterHeaderDanTombolBuat() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Buttons
          Expanded(
            child: Row(
              children: [
                _buildFilterButton(ThreadFilter.all, 'Semua Thread'),
                const SizedBox(width: 8),
                _buildFilterButton(ThreadFilter.myThreads, 'Thread Saya'),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // + Buat Thread Diskusi Baru Button
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateThreadPage()),
              );
              if (result is NewThreadData) {
                _addThread(result);
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Thread Diskusi Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThreadFilter filter, String label) {
    final bool isSelected = _selectedFilter == filter;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: isSelected ? Colors.indigo : Colors.white,
          side: BorderSide(color: Colors.indigo.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Colors.blueGrey.shade800,
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('GymBuddy', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'GymBuddy adalah platform kebugaran berbasis web untuk menemani kegiatan workout kamu', 
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text('Contact Us', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('gymbuddy@gmail.com', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 20),
          const Text('© 2024 GymBuddy. Made with Open Dikskusi', style: TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildThreadItem(NewThreadData thread, int originalIndex, bool isOwner) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadDetailScreen(threadId: thread.id), 
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(thread.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.indigo)),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(thread.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 10),
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  const Text('Pada 26 November 2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Divider(height: 15),

              // Content
              Text(thread.content, style: const TextStyle(fontSize: 13)),
              
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      // Tombol Edit
                      TextButton(
                        onPressed: () async {
                          final updatedResult = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditThreadPage(currentThread: thread, threadIndex: thread.id),
                            ),
                          );
                          if (updatedResult is NewThreadData) {
                            _updateThread(originalIndex, updatedResult);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade50,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        child: const Text('Edit', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Delete
                      TextButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Hapus Thread"),
                            content: const Text("Anda yakin ingin menghapus thread ini?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                              TextButton(
                                onPressed: () {
                                  _deleteThread(originalIndex);
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade50,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  // --- WIDGET UTAMA ---
  @override
  Widget build(BuildContext context) {
    final currentFilteredList = filteredThreads;

    Widget content;
    
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    } else if (currentFilteredList.isEmpty) {
      content = Center(child: Text(_selectedFilter == ThreadFilter.myThreads ? "Anda belum membuat thread." : "Tidak ada thread ditemukan.", style: const TextStyle(fontSize: 16, color: Colors.grey)));
    } else {
      content = ListView.builder( 
        itemCount: currentFilteredList.length,
        itemBuilder: (context, index) {
          final thread = currentFilteredList[index];
          final originalIndex = allThreads.indexOf(thread); 
          final bool isOwner = thread.username == _currentLoggedInUsername;

          return _buildThreadItem(thread, originalIndex, isOwner);
        },
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [ 
          _buildBanner(), // Banner
          _buildFilterHeaderDanTombolBuat(), // Filter dan Tombol Create
          
          Expanded(child: content), // Daftar Thread
          
          _buildFooter(), // Footer (Abu-Abu)
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThreadPage()),
          );

          if (result is NewThreadData) { _addThread(result); }
        },
        tooltip: 'Buat Thread Baru', child: const Icon(Icons.add), backgroundColor: Colors.blueAccent,
      ),
    );
  }
}