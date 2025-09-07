import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/auth_repository.dart';
import '../data/notes_repository.dart';

final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository());

final notesBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox('notes_box');
});

final notesRepoProvider = FutureProvider<NotesRepository>((ref) async {
  final box = await ref.watch(notesBoxProvider.future);
  return NotesRepository(box);
});
