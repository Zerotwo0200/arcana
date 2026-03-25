import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  // Для локальной разработки через docker-compose:
  static const String baseUrl = 'http://localhost:8000';

  String? _token;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    notifyListeners();
  }

  Future<String?> register(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 201) return null;
      final data = jsonDecode(res.body);
      return data['detail'] ?? 'Ошибка регистрации';
    } catch (e) {
      return 'Нет соединения с сервером';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _saveToken(data['access_token']);
        return null;
      }
      final data = jsonDecode(res.body);
      return data['detail'] ?? 'Ошибка входа';
    } catch (e) {
      return 'Нет соединения с сервером';
    }
  }

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };
}
