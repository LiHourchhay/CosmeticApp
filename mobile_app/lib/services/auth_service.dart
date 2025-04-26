import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _baseUrl =
      'http://localhost:3000/api/user'; // Change localhost if testing on real device

  /// Sends login request, stores JWT and full user info on success
  static Future<Map<String, dynamic>> login(
      String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameOrEmail,
        'email': usernameOrEmail, // send both, backend expects either
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final message = json.decode(response.body)['message'] ?? 'Login failed';
      throw Exception(message);
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'];

    // Store token and some user details
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    await prefs.setString('user_id', user['id']);
    await prefs.setString('username', user['username']);
    await prefs.setString('role', user['role']); // save role too

    return data;
  }

  /// Retrieves stored JWT, or null if none.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  /// Retrieves stored username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  /// Retrieves stored role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  /// Removes stored JWT and user info (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('role');
  }

  /// Check if logged-in user is admin
  static Future<bool> isAdmin() async {
    final role = await getRole();
    if (role == null) return false;
    return role.toLowerCase() ==
        'admin'; // Ensure role is correctly stored and checked
  }

  /// Decode JWT payload if needed
  static Future<Map<String, dynamic>?> decodeToken() async {
    final token = await getToken();
    if (token == null) return null;
    return JwtDecoder.decode(token);
  }
}
