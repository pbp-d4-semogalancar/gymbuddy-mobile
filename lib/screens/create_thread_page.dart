import 'package:flutter/material.dart';
import 'dart:async';
import '../models/community_thread.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class CreateThreadPage extends StatefulWidget {
  const CreateThreadPage({super.key});

  @override
  State<CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _submitThread(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = context.read<CookieRequest>();
    final postUrl = "http://localhost:8000/community/api/threads/";

    setState(() {
      _isLoading = true;
    });

    // ====================================================================
    // 💡 CSRF FIX: Force a GET request to ensure the 'csrftoken' cookie
    // is present in the CookieRequest instance before attempting a POST.
    // The server typically sends this cookie on an initial GET request.
    // ====================================================================
    try {
      print("Attempting preliminary GET request to acquire CSRF cookie...");
      await request.get(postUrl);
      print("CSRF cookie potentially acquired.");
    } catch (e) {
      // It's okay if this GET fails, we just want to force a cookie set.
      print("Warning: Preliminary GET failed, continuing to POST. Error: $e");
    }
    
    // ================================
    // 🔥 DEBUG LOG
    // ================================
    print("========== POSTING THREAD ==========");
    print("Logged in: ${request.loggedIn}");
    print("POST URL: $postUrl");
    print("Title: ${_titleController.text}");
    print("Content: ${_contentController.text}");

    try {
      final Map<String, dynamic> data = {
        "title": _titleController.text,
        "content": _contentController.text,
      };

      final response = await request.post(
        postUrl,
        data,
      );

      print("SERVER RESPONSE:");
      print(response);

      if (context.mounted) {
        if (response.containsKey('id') && response['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Thread berhasil dibuat!")),
          );

          final newThread = NewThreadData(
            id: response['id'] as int,
            title: response['title'] as String,
            content: response['content'] as String,
            // Use safe access in case 'author_username' is missing or null
            username: response['author_username'] ?? 'Anonymous', 
            isMine: true,
          );

          _resetForm();
          // Pop the page and return the new thread data to the previous screen
          Navigator.pop(context, newThread); 
        } else {
          // Handle server-side validation or login failure response
          String errorMsg =
              response['detail'] ?? "Gagal posting thread. Pastikan Anda login.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ $errorMsg")),
          );
        }
      }
    } catch (e) {
      print("ERROR TERJADI:");
      print(e);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Terjadi kesalahan koneksi. Pastikan server Django berjalan.",
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Thread Baru'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Judul Thread', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul tidak boleh kosong!' : null,
              ),
              const SizedBox(height: 12.0),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                    labelText: 'Isi Konten Diskusi',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Konten tidak boleh kosong!' : null,
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitThread(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white, // Ensure foreground color for text
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'POST THREAD',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}