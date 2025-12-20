import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // URL Domain
  final String domain = kIsWeb
      ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
      : "http://10.0.2.2:8000";

  Future<void> _submitThread(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Anda harus login terlebih dahulu!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // [PERBAIKAN 1] Gunakan endpoint 'api/threads/' yang sudah ada di urls.py
      // Endpoint ini menggunakan ThreadListCreateAPIView yang aman untuk mobile.
      final response = await request.post("$domain/community/api/threads/", {
        "title": _titleController.text,
        "content": _contentController.text,
      });

      // [PERBAIKAN 2] Sesuaikan parsing respon dengan ThreadSerializer
      // ThreadSerializer mengembalikan field: id, title, content, author_username, date_created

      // Cek apakah response memiliki ID (tanda sukses dibuat)
      if (response != null && response['id'] != null) {
        final newThread = NewThreadData(
          id: response['id'],
          title: response['title'],
          content: response['content'],
          // Serializer Anda mengirim key 'author_username', bukan 'username'
          username:
              response['author_username'] ??
              request.jsonData['username'] ??
              "Me",
          isMine: true,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Thread berhasil dibuat!")),
          );
          Navigator.pop(context, newThread);
        }
      } else {
        // Handle error jika ada pesan detail dari Django REST Framework
        String errorMsg = "Gagal membuat thread.";
        if (response['detail'] != null) {
          errorMsg = response['detail'];
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ $errorMsg")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thread Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Thread',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                ),
                cursorColor: Colors.black,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul tidak boleh kosong!' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Konten Diskusi',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty
                    ? 'Konten tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitThread(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'POST THREAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
