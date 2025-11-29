// lib/screens/edit_thread_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/community_thread.dart'; 
import 'package:provider/provider.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart'; 

class EditThreadPage extends StatefulWidget {
  final NewThreadData currentThread;
  final int threadIndex; // Menggunakan ID Django

  const EditThreadPage({
    super.key,
    required this.currentThread,
    required this.threadIndex,
  });

  @override
  State<EditThreadPage> createState() => _EditThreadPageState();
}

class _EditThreadPageState extends State<EditThreadPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentThread.title);
    _contentController = TextEditingController(text: widget.currentThread.content);
  }

  Future<void> _submitEdit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    
    setState(() { _isLoading = true; });

    try {
      // Data dikirim sebagai Form Data (String Map)
      final Map<String, dynamic> data = {
        "title": _titleController.text,
        "content": _contentController.text,
      };

      // PERBAIKAN URL: Menggunakan localhost
      // Menggunakan request.post (Non-JSON) untuk endpoint AJAX
      final response = await request.post(
        "http://localhost:8000/community/edit/${widget.threadIndex}/", 
        data,
      );

      if (context.mounted) {
          // Asumsi respons AJAX sukses adalah {success: true}
          if (response.containsKey('success') && response['success'] == true) { 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Thread berhasil diperbarui!")),
              );

              // Memanggil constructor dengan named required arguments
              final updatedThread = NewThreadData(
                id: widget.currentThread.id, 
                title: _titleController.text,
                content: _contentController.text,
                username: widget.currentThread.username,
                isMine: widget.currentThread.isMine,
              );

              Navigator.pop(context, updatedThread);
          } else {
              // Tangani error validasi form dari Django
              String errorMsg = response['error'] ?? "Gagal menyimpan. Pastikan Anda pemilik thread.";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Gagal menyimpan perubahan: $errorMsg")),
              );
          }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan koneksi/server.")),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
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
        title: const Text('Edit Thread'),
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
              Text(
                "Mengedit Thread milik: ${widget.currentThread.username}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20.0),
              
              // Field Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Thread', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Judul tidak boleh kosong!' : null,
              ),
              const SizedBox(height: 12.0),

              // Field Konten
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Isi Konten Diskusi', border: OutlineInputBorder()),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Konten tidak boleh kosong!' : null,
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitEdit(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}