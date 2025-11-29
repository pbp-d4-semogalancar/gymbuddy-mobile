// lib/models/community_thread.dart

import 'package:flutter/material.dart';

// Class untuk membawa data thread di aplikasi
class NewThreadData {
  final int id; // <-- FIELD BARU: ID dari Django (Wajib)
  final String title;
  final String content;
  final String username;
  final bool isMine; 
  
  // Menggunakan named required parameters
  NewThreadData({
    required this.id, // <-- HARUS ADA ID
    required this.title, 
    required this.content, 
    this.username = "Mock User", 
    this.isMine = false,
  });

  // --- FACTORY CONSTRUCTOR UNTUK JSON DJANGO ---
  factory NewThreadData.fromJson(Map<String, dynamic> json, String currentUsername) {
    final threadUsername = json['author_username'] as String? ?? 'Unknown User';

    return NewThreadData(
      id: json['id'] as int, // Membaca ID dari respons JSON
      title: json['title'] as String,
      content: json['content'] as String,
      username: threadUsername,
      // Tentukan kepemilikan berdasarkan username di Flutter
      isMine: threadUsername == currentUsername, 
    );
  }
}