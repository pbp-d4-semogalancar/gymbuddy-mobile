import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gymbuddy/widgets/left_drawer.dart';
import 'package:gymbuddy/widgets/user_avatar.dart';
import 'package:gymbuddy/screens/howto_page.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'create_thread_page.dart';
import 'edit_thread_page.dart';
import '../models/community_thread.dart';
import 'thread_detail.dart';

enum ThreadFilter { all, myThreads }

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Kita tidak butuh logic username manual lagi, karena backend sudah kasih 'is_mine'
  // String _currentLoggedInUsername = "Loading...";

  ThreadFilter _selectedFilter = ThreadFilter.all;
  List<NewThreadData> allThreads = [];
  bool _isLoading = true;
  String? _error;

  final String domain = kIsWeb
      ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
      : "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchThreads();
    });
  }

  // [BAGIAN YANG DIPERBAIKI LOGICNYA]
  Future<void> _fetchThreads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();

    try {
      final response = await request.get('$domain/community/api/threads/');

      List<NewThreadData> threads = [];

      for (var d in response) {
        if (d != null) {
          // KITA MANUALKAN PEMBUATAN OBJEK AGAR MEMBACA 'is_mine' DARI BACKEND
          // (Asumsi model NewThreadData punya constructor seperti ini)
          NewThreadData thread = NewThreadData(
            id: d['id'],
            title: d['title'],
            content: d['content'],
            // Backend serializer mengirim 'author_username'
            username: d['author_username'] ?? d['username'] ?? "User",
            // [KUNCI FIX] Ambil boolean langsung dari backend
            isMine: d['is_mine'] ?? false,
          );

          threads.add(thread);
        }
      }

      setState(() {
        allThreads = threads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Gagal memuat data: $e";
        _isLoading = false;
      });
    }
  }

  void _addThread(NewThreadData newThread) {
    setState(() {
      allThreads.insert(0, newThread);
    });
    _fetchThreads();
  }

  Future<void> _deleteThread(int threadId) async {
    final request = context.read<CookieRequest>();
    try {
      // [PERBAIKAN] Sesuaikan URL dengan urls.py: 'delete/<int:thread_id>/'
      final response = await request.post(
        '$domain/community/delete/$threadId/',
        {},
      );

      // Cek variasi respon backend
      if (response['status'] == 'success' || response['success'] == true) {
        setState(() {
          allThreads.removeWhere((t) => t.id == threadId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thread berhasil dihapus")),
          );
        }
      } else {
        if (mounted) {
          String msg = response['message'] ?? "Gagal menghapus thread";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$msg")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- WIDGETS (UI TETAP SAMA PERSIS) ---
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
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.network(
                "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470",
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: Colors.grey.shade900);
                },
                errorBuilder: (ctx, error, stackTrace) =>
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
                      "Community Forum",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
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
                      "Connect, Share, and Grow Together",
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildFilterBtn("All Threads", ThreadFilter.all),
          _buildFilterBtn("My Threads", ThreadFilter.myThreads),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String text, ThreadFilter filter) {
    bool isActive = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.grey.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThreadItem(NewThreadData thread) {
    String dateDisplay = "Just now";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadDetailScreen(threadId: thread.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      thread.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        thread.username,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateDisplay,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              Text(
                thread.content,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (thread.isMine) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditThreadPage(
                              currentThread: thread,
                              threadIndex: thread.id,
                            ),
                          ),
                        );
                        if (result == true) _fetchThreads();
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => _deleteThread(thread.id),
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [FIX] Filter menggunakan property isMine yang sudah benar dari backend
    final currentList = _selectedFilter == ThreadFilter.all
        ? allThreads
        : allThreads.where((t) => t.isMine).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const LeftDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          Widget page;
          switch (index) {
            case 0:
              page = const MyHomePage();
              break;
            case 1:
              page = const HowtoPage();
              break;
            case 2:
              page = const LogActivityPage();
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
              child: RefreshIndicator(
                onRefresh: _fetchThreads,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _headerBanner(),
                      _filterSection(),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(),
                        )
                      else if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              ElevatedButton(
                                onPressed: _fetchThreads,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      else if (currentList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selectedFilter == ThreadFilter.myThreads
                                    ? "Anda belum membuat thread."
                                    : "Belum ada thread.",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            return _buildThreadItem(currentList[index]);
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThreadPage()),
          );
          if (result is NewThreadData) {
            _addThread(result);
          } else if (result == true) {
            _fetchThreads();
          }
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Thread", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
