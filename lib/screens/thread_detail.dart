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
  final TextEditingController _replyController = TextEditingController();
  final String domain = kIsWeb
      ? "http://127.0.0.1:8000"
      : "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _fetchThreadData();
  }

  Future<void> _fetchThreadData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        '$domain/community/api/thread/${widget.threadId}/',
      );
      setState(() {
        _thread = ThreadDetail.fromJson(response['thread']);
        _replies = (response['replies'] as List)
            .map((i) => Reply.fromJson(i))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.postJson(
        '$domain/community/api/thread/${widget.threadId}/add_reply/', 
        jsonEncode(<String, String>{
          'content': _replyController.text,
        }),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        _replyController.clear();
        _fetchThreadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Balasan berhasil dikirim!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal mengirim balasan.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thread Detail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thread Content
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
                        const Text(
                          "Replies",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Replies List
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
                          ..._replies
                              .map((reply) => _buildReplyItem(reply))
                              .toList(),
                      ],
                    ),
                  ),
                ),

                // Reply Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Tulis balasan...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _postReply,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReplyItem(Reply reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(reply.user.avatarUrl),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  reply.user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(reply.content),
          ],
        ),
      ),
    );
  }
}
