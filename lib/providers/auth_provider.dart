import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _token = '';
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String get token => _token;

  void login(String token) {
    _token = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _token = '';
    _isAuthenticated = false;
    notifyListeners();
  }
}
