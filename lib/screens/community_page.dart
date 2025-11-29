// lib/screens/community_page.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart'; 
import 'create_thread_page.dart'; 
import 'edit_thread_page.dart'; 
import '../models/community_thread.dart'; 

// Enum untuk mengontrol state filter
enum ThreadFilter { all, myThreads }

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // --- USERNAME DARI SCREENSHOT ANDA: 'deryyy' ---
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
      
      // Menggunakan localhost untuk Chrome
      final response = await request.get("http://localhost:8000/community/api/threads/"); 

      if (response is List) {
        final fetchedThreads = response.map((data) {
          return NewThreadData.fromJson(data as Map<String, dynamic>, _currentLoggedInUsername);
        }).toList();
        
        setState(() {
          allThreads = fetchedThreads.reversed.toList(); // Tampilkan dari terbaru
        });
        
      } else {
        throw Exception("Invalid response format from server.");
      }

    } catch (e) {
      setState(() {
        _error = "Gagal memuat thread. Pastikan Anda sudah login di Flutter.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
  void _deleteThread(int originalIndex) async {
    final threadToDelete = allThreads[originalIndex];
    final request = context.read<CookieRequest>();
    
    // PERBAIKAN: Menggunakan ID thread dari model
    final threadId = threadToDelete.id; 

    try {
        // Menggunakan endpoint DELETE AJAX yang Anda miliki
        final response = await request.post(
            "http://localhost:8000/community/delete/${threadId}/", // <-- URL localhost
            {} // Body kosong
        );
        
        if (response['status'] == 'success') { 
            setState(() {
                allThreads.removeAt(originalIndex);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Thread berhasil dihapus.")),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Gagal menghapus thread: ${response['message'] ?? 'Server error.'}")),
            );
        }

    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Terjadi kesalahan koneksi saat menghapus.")),
        );
    }
  }


  // --- WIDGET HELPER LENGKAP ---
  
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

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white, 
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterButton(ThreadFilter.all, 'Semua Thread'),
            const SizedBox(width: 10),
            _buildFilterButton(ThreadFilter.myThreads, 'Thread Saya'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: Colors.indigo.shade50,
      alignment: Alignment.center,
      child: const Text(
        "© 2025 GymBuddy Community | All Rights Reserved",
        style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w500),
      ),
    );
  }

  // --- END WIDGET HELPER ---


  @override
  Widget build(BuildContext context) {
    final currentFilteredList = filteredThreads;

    Widget content;
    
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    } else if (currentFilteredList.isEmpty) {
      content = Center(
        child: Text(
          _selectedFilter == ThreadFilter.myThreads 
              ? "Anda belum membuat thread." 
              : "Tidak ada thread ditemukan.",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      content = ListView.builder( 
        itemCount: currentFilteredList.length,
        itemBuilder: (context, index) {
          final thread = currentFilteredList[index];
          
          final originalIndex = allThreads.indexOf(thread); 
          
          final bool isOwner = thread.username == _currentLoggedInUsername;

          return Column(
            children: [
              InkWell( 
                onTap: () {
                  // Navigasi ke Detail
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. User Header & Metrics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.indigo,
                                child: Icon(Icons.person, size: 14, color: Colors.white), 
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama akun yang benar
                                  Text(thread.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), 
                                  const Text("Posted Just Now", style: TextStyle(fontSize: 10, color: Colors.grey)), 
                                ],
                              ),
                            ],
                          ),
                          // Placeholder Metrics
                          if (!isOwner)
                            const Text(
                              "0 Replies", 
                              style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),

                      // 2. Title dan Content
                      Text(thread.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), 
                      const SizedBox(height: 6),
                      Text(thread.content, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      
                      // 3. Tombol Edit/Delete
                      if (isOwner)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Tombol EDIT
                              TextButton(
                                onPressed: () async {
                                    final updatedResult = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditThreadPage(
                                          currentThread: thread,
                                          threadIndex: thread.id, // <-- KIRIM ID THREAD YANG BENAR
                                        ),
                                      ),
                                    );
                                    if (updatedResult is NewThreadData) {
                                      _updateThread(originalIndex, updatedResult);
                                    }
                                },
                                child: const Text('Edit', style: TextStyle(color: Colors.green)),
                              ),
                              // Tombol DELETE
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
                                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: Color.fromARGB(255, 230, 230, 230)),
            ],
          );
        },
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Community Threads'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0, 
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          
          Expanded(
            child: content,
          ),
          
          _buildFooter(),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThreadPage()),
          );

          if (result is NewThreadData) { 
             _addThread(result); 
          }
        },
        tooltip: 'Buat Thread Baru',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}