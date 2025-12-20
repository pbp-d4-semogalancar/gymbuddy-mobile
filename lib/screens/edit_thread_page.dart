import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/community_thread.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditThreadPage extends StatefulWidget {
  final NewThreadData currentThread;
  final int threadIndex;

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

  final String domain = kIsWeb
      ? "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id"
      : "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentThread.title);
    _contentController = TextEditingController(
      text: widget.currentThread.content,
    );
  }

  Future<void> _submitEdit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      request.headers['X-Requested-With'] = 'XMLHttpRequest';

      final response = await request.post(
        "$domain/community/edit/${widget.threadIndex}/",
        {
          "title": _titleController.text,
          "content": _contentController.text,
        },
      );

      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perubahan berhasil disimpan!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? "Gagal menyimpan.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Gagal: Pastikan ID Thread benar. ($e)")),
        );
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
          'Edit Thread',
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
                  onPressed: _isLoading ? null : () => _submitEdit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // TOMBOL HITAM
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'SIMPAN PERUBAHAN',
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
