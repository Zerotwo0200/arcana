import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;
  bool get isLoggedIn => _token != null;

  AuthService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<void> _saveToPrefs(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
    _token = token;
    _email = email;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    _token = null;
    _email = null;
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
        await _saveToPrefs(data['access_token'], email);
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
