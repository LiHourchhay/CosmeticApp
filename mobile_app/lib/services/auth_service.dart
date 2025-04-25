import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// A service for authentication and authorization tasks.
class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/user';

  /// Sends login request, stores JWT and username on success, and returns decoded user info.
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      final message = json.decode(response.body)['message'] ?? 'Login failed';
      throw Exception(message);
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;

    // Store token and username
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    await prefs.setString('username', username);

    return data;
  }

  /// Retrieves stored JWT, or null if none.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  /// Retrieves stored username, or null if not set.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  /// Removes stored JWT and username (logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('username');
  }

  /// Returns true if the stored JWT exists and has role "admin".
  static Future<bool> isAdmin() async {
    final token = await getToken();
    if (token == null) return false;
    final decoded = JwtDecoder.decode(token);
    return decoded['role'] == 'admin';
  }
}
