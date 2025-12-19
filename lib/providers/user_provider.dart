import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  String? _username;

  int? get userId => _userId;
  String? get username => _username;

  // fungsi untuk menyimpan data saat Login berhasil
  void setUser(int id, String uname) {
    _userId = id;
    _username = uname;
    notifyListeners();
  }

  // fungsi reset data saat Logout
  void logout() {
    _userId = null;
    _username = null;
    notifyListeners();
  }
}