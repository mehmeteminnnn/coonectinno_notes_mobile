import 'package:flutter/material.dart';
import 'package:connectinno_notes/src/ui/login_screen.dart';
import 'package:connectinno_notes/src/ui/notes_list_screen.dart';
import 'package:connectinno_notes/src/ui/note_edit_screen.dart';
import 'package:connectinno_notes/src/ui/splash_screen.dart';
import 'package:connectinno_notes/src/theme/app_transitions.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String notes = '/notes';
  static const String edit = '/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return FadeRoute(
          page: const SplashScreen(),
        );
      case login:
        return SlideRightRoute(
          page: const LoginScreen(),
          begin: const Offset(1.0, 0.0),
        );
      case notes:
        return ScaleRoute(
          page: const NotesListScreen(),
        );
      case edit:
        final args = settings.arguments as Map<String, dynamic>?;
        return SlideUpRoute(
          page: NoteEditScreen(
            noteId: args?['id'] as String?,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
