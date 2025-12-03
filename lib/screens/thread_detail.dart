import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../models/community_reply.dart'; // Pastikan path ini benar

class ThreadDetailScreen extends StatefulWidget {
  final int threadId;

  const ThreadDetailScreen({super.key, required this.threadId});

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  // --- STATE VARIABLES ---
  ThreadDetail? _thread;
  List<Reply> _replies = [];
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _sortOrder = 'newest';

  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchThreadData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // ==========================================
  // 1. FETCH DATA (API)
  // ==========================================
  Future<void> _fetchThreadData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://localhost:8000/community/api/thread/${widget.threadId}/',
      );

      setState(() {
        _thread = ThreadDetail.fromJson(response['thread']);
        var list = response['replies'] as List;
        _replies = list.map((d) => Reply.fromJson(d)).toList();
        _sortReplies();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 2. SORTING LOGIC
  // ==========================================
  void _sortReplies() {
    setState(() {
      if (_sortOrder == 'newest') {
        _replies.sort((a, b) => b.id.compareTo(a.id));
      } else {
        _replies.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  // ==========================================
  // 3. ADD REPLY (LOGIC & DIALOG)
  // ==========================================
  void _showAddReplyDialog({int? parentId, String? replyToUser}) {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parentId == null ? "Tambah Balasan" : "Balas ke $replyToUser"),
        content: TextField(
          controller: _replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Tulis balasanmu di sini...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReply(parentId: parentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReply({int? parentId}) async {
    if (_replyController.text.isEmpty) return;
    final request = context.read<CookieRequest>();
    setState(() => _isActionLoading = true);

    try {
      final response = await request.postJson(
        'http://localhost:8000/community/api/thread/${widget.threadId}/add_reply/',
        jsonEncode({
          'content': _replyController.text,
          'parent_id': parentId,
        }),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Balasan terkirim!")));
        _fetchThreadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Gagal: ${response['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan koneksi.")));
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // ==========================================
  // 4. EDIT REPLY (LOGIC & DIALOG)
  // ==========================================
  void _showEditReplyDialog(Reply reply) {
    _replyController.text = reply.content;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Balasan"),
        content: TextField(
          controller: _replyController,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editReply(reply.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _editReply(int replyId) async {
    final request = context.read<CookieRequest>();
    setState(() => _isActionLoading = true);

    try {
      final response = await request.postJson(
        'http://localhost:8000/community/api/reply/$replyId/edit/',
        jsonEncode({'content': _replyController.text}),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Balasan diperbarui!")));
        _fetchThreadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Gagal: ${response['message']}")));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // ==========================================
  // 5. DELETE REPLY (LOGIC & DIALOG)
  // ==========================================
  void _showDeleteConfirmDialog(int replyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Balasan"),
        content: const Text("Apakah Anda yakin ingin menghapus balasan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReply(replyId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReply(int replyId) async {
    final request = context.read<CookieRequest>();
    setState(() => _isActionLoading = true);

    try {
      final response = await request.post(
        'http://localhost:8000/community/api/reply/$replyId/delete/',
        jsonEncode({}),
      );

      if (response['status'] == 'success') {
        setState(() {
          _replies.removeWhere((r) => r.id == replyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Balasan dihapus!")));
        _fetchThreadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Gagal: ${response['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus.")));
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // ==========================================
  // UI BUILDER
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "GymBuddy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _thread == null
              ? const Center(child: Text("Thread tidak ditemukan"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isActionLoading) const LinearProgressIndicator(),

                      _buildHeroSection(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tombol Kembali
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text("Kembali"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Main Thread Card
                            _buildThreadCard(_thread!),

                            const SizedBox(height: 30),

                            // Replies Header
                            _buildRepliesHeader(),

                            const SizedBox(height: 16),

                            // Replies List
                            if (_replies.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: Text("Belum ada balasan. Jadilah yang pertama!", style: TextStyle(color: Colors.grey))),
                              )
                            else
                              ..._replies.map((reply) => _buildReplyItem(reply, depth: 0)),
                          ],
                        ),
                      ),

                      _buildFooter(),
                    ],
                  ),
                ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Thread 📝 & Reply 💬:\nCommunity Discussion",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Tanyakan untuk memahami lebih banyak\nkegiatan workout di sini!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadCard(ThreadDetail thread) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thread.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                    backgroundImage: NetworkImage(thread.user.avatarUrl),
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                  ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thread.user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Pada ${thread.user.timeAgo}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            thread.content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Replies:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddReplyDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Tambah balasan"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(20)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortOrder,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  dropdownColor: Colors.grey[700],
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortOrder = newValue;
                        _sortReplies();
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text("Terbaru")),
                    DropdownMenuItem(value: 'oldest', child: Text("Terlama")),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildReplyItem(Reply reply, {int depth = 0}) {
    double indent = (depth * 40.0).clamp(0.0, 200.0);
    
    const int maxDepth = 5;
    bool canReply = depth < maxDepth;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12, left: indent),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
            border: depth > 0 ? Border(left: BorderSide(color: Colors.grey.shade400, width: 3)) : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundImage: NetworkImage(reply.user.avatarUrl), radius: 18, backgroundColor: Colors.grey.shade300),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(reply.user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Pada ${reply.user.timeAgo}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])
            ]),
            const SizedBox(height: 12),
            Text(reply.content, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 16),
            
            Row(children: [
              if (canReply) ...[
                _actionButton("Balas", () => _showAddReplyDialog(parentId: reply.id, replyToUser: reply.user.displayName)),
                const SizedBox(width: 8),
              ] else ...[
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    shape: const StadiumBorder(),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    disabledForegroundColor: Colors.red,
                  ),
                  child: const Text("Balas", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],

              if (reply.isMine) ...[
                _actionButton("Edit", () => _showEditReplyDialog(reply)),
                const SizedBox(width: 8),
                _actionButton("Delete", () => _showDeleteConfirmDialog(reply.id)),
              ],
            ])
          ]),
        ),
        if (reply.children.isNotEmpty) ...reply.children.map((child) => _buildReplyItem(child, depth: depth + 1)),
      ],
    );
  }


  Widget _actionButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF333333),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("GymBuddy", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("GymBuddy adalah platform kebugaran berbasis\nweb untuk menemani kegiatan workout kamu 💪", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          const Text("Contact Us", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const Text("gymbuddy@gmail.com", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Center(child: Text("© 2025 GymBuddy. Hak Cipta Dilindungi.", style: TextStyle(color: Colors.white54, fontSize: 10))),
        ],
      ),
    );
  }
}