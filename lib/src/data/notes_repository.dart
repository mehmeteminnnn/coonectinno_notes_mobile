import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/config.dart';

class NoteDto {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  NoteDto({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) => NoteDto(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );
}

class NotesRepository {
  final Box _box;

  NotesRepository(this._box);

  Future<List<NoteDto>> listNotes(String idToken) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/notes/');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $idToken'},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as List<dynamic>;
        await _box.put('notes', res.body);
        return body
            .map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('List notes failed: ${res.statusCode} ${res.body}');
      throw Exception('Listeleme basarisiz: ${res.statusCode}');
    } catch (_) {
      debugPrint('List notes exception');
      // Offline: cache'e don
      final cached = _box.get('notes') as String?;
      if (cached != null) {
        final body = jsonDecode(cached) as List<dynamic>;
        return body
            .map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<String> createNote(
    String idToken, {
    required String title,
    required String content,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/notes/');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['id'] as String;
    }
    debugPrint('Create note failed: ${res.statusCode} ${res.body}');
    throw Exception('Olusturma basarisiz: ${res.statusCode} - ${res.body}');
  }

  Future<void> updateNote(
    String idToken,
    String id, {
    String? title,
    String? content,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/notes/$id');
    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    if (res.statusCode != 204) {
      debugPrint('Update note failed: ${res.statusCode} ${res.body}');
      throw Exception('Guncelleme basarisiz: ${res.statusCode}');
    }
  }

  Future<void> deleteNote(String idToken, String id) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/notes/$id');
    final res = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (res.statusCode != 204) {
      debugPrint('Delete note failed: ${res.statusCode} ${res.body}');
      throw Exception('Silme basarisiz: ${res.statusCode}');
    }
  }
}
