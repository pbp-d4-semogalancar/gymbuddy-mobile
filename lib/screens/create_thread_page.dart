// lib/screens/create_thread_page.dart

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
    
    if (!request.loggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Anda harus login terlebih dahulu!")),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

    setState(() {
      _isLoading = true; 
    });

    try {
      final Map<String, dynamic> data = {
        "title": _titleController.text,
        "content": _contentController.text,
      };

      print("Logged in: ${request.loggedIn}");
      print("Mengirim data ke server: $data");


      // PERBAIKAN URL: Menggunakan localhost untuk Chrome
      final response = await request.post(
       "http://localhost:8000/community/api/thread/create/", 
        data,
      );

      print("Response dari server: $response");

      if (context.mounted) {
          if (response.containsKey('id') && response['id'] != null) { 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Thread berhasil dibuat!")),
              );
              
              // FIX: Memanggil constructor dengan named required arguments
              final newThread = NewThreadData(
                id: response['id'] as int, // <-- KIRIM ID DARI RESPONSE
                title: response['title'] as String, 
                content: response['content'] as String, 
                username: response['username'], 
                isMine: true, 
              );
              
              _resetForm(); 
              Navigator.pop(context, newThread); 
              
          } else {
              // Menangkap error 403 Forbidden atau validasi gagal
              String errorMsg = response['detail'] ?? "Gagal posting thread. Pastikan Anda sudah login.";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Gagal posting: $errorMsg")),
              );
          }
      }
    } catch (e) {
      if (context.mounted) {
        // Menangkap error koneksi umum
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan koneksi. Pastikan server Django berjalan.")),
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
                onPressed: _isLoading ? null : () => _submitThread(context), 
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'POST THREAD',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}