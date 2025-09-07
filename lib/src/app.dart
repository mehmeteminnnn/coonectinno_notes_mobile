import 'package:flutter/material.dart';
import 'package:connectinno_notes/src/routes.dart';
import 'package:connectinno_notes/src/theme/app_theme.dart';

class ConnectInnoNotesApp extends StatelessWidget {
  const ConnectInnoNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectInno Notes',
      theme: AppTheme.theme,
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}
