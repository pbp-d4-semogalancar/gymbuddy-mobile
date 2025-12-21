import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/community_reply.dart';

class ThreadDetailScreen extends StatefulWidget {
  final int threadId;

  const ThreadDetailScreen({super.key, required this.threadId});

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  ThreadDetail? _thread;
  List<Reply> _replies = [];
  bool _isLoading = true;
  String _sortOrder = 'newest';
  int? _replyingToId; 
  String? _replyingToName;

  final TextEditingController _replyController = TextEditingController();
  
  final String domain = kIsWeb
      ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
      : "http://10.0.2.2:8000";

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

  Future<void> _fetchThreadData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$domain/community/api/thread/${widget.threadId}/');
      setState(() {
        _thread = ThreadDetail.fromJson(response['thread']);
        _replies = (response['replies'] as List)
            .map((i) => Reply.fromJson(i))
            .toList();
        _sortReplies();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _sortReplies() {
    setState(() {
      if (_sortOrder == 'newest') {
        _replies.sort((a, b) => b.id.compareTo(a.id));
      } else {
        _replies.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        '$domain/community/api/thread/${widget.threadId}/add_reply/', 
        jsonEncode({'content': _replyController.text, 'parent_id': _replyingToId}),
      );
      if (response['status'] == 'success') {
        setState(() {
          _replyController.clear();
          _replyingToId = null;
          _replyingToName = null;
        });
        _fetchThreadData();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Widget> _buildReplyTree(List<Reply> replies, double indent, int depth) {
    List<Widget> tree = [];
    for (var reply in replies) {
      tree.add(
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: _buildReplyItem(reply, depth),
        ),
      );
      if (reply.children.isNotEmpty && depth < 5) {
        tree.addAll(_buildReplyTree(reply.children, (indent + 12).clamp(0, 60), depth + 1));
      }
    }
    return tree;
  }

  Widget _buildReplyItem(Reply reply, int depth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300, width: 1.5)),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(left: 8),
        color: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16, 
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage(reply.user.avatarUrl)
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reply.user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          reply.user.timeAgo,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (depth < 5)
                    IconButton(
                      icon: const Icon(Icons.reply, size: 18, color: Colors.green),
                      onPressed: () => setState(() {
                        _replyingToId = reply.id;
                        _replyingToName = reply.user.displayName;
                      }),
                    ),
                  if (reply.isMine) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                      onPressed: () => _showEditDialog(reply),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(reply.id),
                    ),
                  ],
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 42, bottom: 4),
                child: Text(reply.content, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Reply reply) {
    TextEditingController editCtrl = TextEditingController(text: reply.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Reply", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editCtrl, 
          maxLines: 3, 
          cursorColor: Colors.black,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.black))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              await request.postJson('$domain/community/api/reply/${reply.id}/edit/', jsonEncode({'content': editCtrl.text}));
              _fetchThreadData();
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Reply", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Pesan ini akan dihapus secara permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.black))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              await request.post('$domain/community/api/reply/$id/delete/', {});
              _fetchThreadData();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thread Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _thread?.title ?? "",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                _thread?.user.avatarUrl ?? "",
                              ),
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _thread?.user.displayName ?? "User",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _thread?.user.timeAgo ?? "",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _thread?.content ?? "",
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const Divider(height: 40, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Replies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sortOrder,
                                  items: const [
                                    DropdownMenuItem(value: 'newest', child: Text("Newest")),
                                    DropdownMenuItem(value: 'oldest', child: Text("Oldest")),
                                  ],
                                  onChanged: (val) {
                                    setState(() { _sortOrder = val!; _sortReplies(); });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_replies.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                "Belum ada balasan.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                        const SizedBox(height: 20),
                        ..._buildReplyTree(_replies, 0, 1),
                      ],
                    ),
                  ),
                ),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.grey.shade200))
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Membalas $_replyingToName", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _replyingToId = null),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    )
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      hintText: "Tulis balasan...", 
                      border: InputBorder.none
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black87),
                  onPressed: _postReply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}