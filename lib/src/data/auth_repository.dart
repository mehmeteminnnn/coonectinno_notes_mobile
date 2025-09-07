import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class AuthRepository {
  String? _idToken;

  String? get idToken => _idToken;

  Future<void> signInWithEmail(String email, String password) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${AppConfig.webApiKey}',
    );
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      _idToken = data['idToken'] as String?;
      return;
    }
    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (err['error']?['message'] ?? '').toString();
      throw Exception('Giris basarisiz: ${res.statusCode} $msg');
    } catch (_) {
      throw Exception('Giris basarisiz: ${res.statusCode}');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${AppConfig.webApiKey}',
    );
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      _idToken = data['idToken'] as String?;
      return;
    }
    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (err['error']?['message'] ?? '').toString();
      throw Exception('Kayit basarisiz: ${res.statusCode} $msg');
    } catch (_) {
      throw Exception('Kayit basarisiz: ${res.statusCode}');
    }
  }

  void signOut() {
    _idToken = null;
  }

  /// Returns true if the user is currently signed in
  bool get isSignedIn => _idToken != null;
}
